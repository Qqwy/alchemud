defmodule Alchemud.World.Location do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  defstruct module: nil, uuid: nil, description: "", name: "", ways: [], exits: [], contents: [], pid: nil
  def transient_fields, do: [:exits, :contents, :pid]
  alias Alchemud.World.Location  

  use ExActor.GenServer

  alias Alchemud.World.{Way, Entity}


  defstart start_link(init_state = %Location{}), gen_server_opts: [name: process_name(init_state)] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    Process.flag(:trap_exit, true) # Trap Entity exits.

    add_incoming_ways(init_state)
    initial_state(init_state)
  end

  def process_name(%Location{uuid: uuid}) do
    {:global, {:location, uuid}}
  end

  defcall get, state: state, do: reply(state) 
  defcall get_contents, state: state, do: reply(state.contents) 

  @doc """
  Lists all Ways that are exits from this location.
  """ 
  defcall exits, state: %Location{exits: exits}, do: reply(exits) 

 
  @doc """
  Adds a Way to the list of tis Location's exits.
  TODO: Find out if storing Way's PID is better than storing its UUID.
  """
  defcall add_exit(way_pid, way = %Way{}), state: state = %Location{exits: exits} do
    Process.monitor(way_pid)
    new_state = %Location{state | exits: [%Way{way | pid: way_pid} | exits]}
    set_and_reply(new_state, :ok)
  end

  @doc """
  When adding an entity, we add a reference to the PID.
  Entities are themselves responsible to save pointers to their locations/containers.
  As the state of the entity might (rapidly!) change, this state is not sent over.
  """
  defcall add_entity(entity_pid, entity = %Entity{}), state: state = %Location{contents: contents} do
    Process.link(entity_pid)
    new_state = %Location{state | contents: [%Entity{entity | pid: entity_pid} | contents]}
    set_and_reply(new_state, :ok)
  end

  @doc """
  Called internally when time has passed.
  """
  defhandleinfo :tick, state: state = %Location{module: location_module} do
    new_state = location_module.handle_tick(state)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end

  @doc """
  - Removes exit(ways) that are down from the `exits` list.
  - Removes entities that are down from the `contents` list.
  """
  defhandleinfo {:DOWN, ref, :process, pid, reason}, state: state = %Location{exits: exits, contents: contents} do
    IO.inspect "[#{inspect self}]:DOWN message received:"
    Apex.ap [ref, pid, reason]

    # Filter exits
    exits = Enum.reject(exits, &match?(%Way{pid: ^pid}, &1) )
    # TODO: Filter contents?
    contents = Enum.reject(contents, &match?(%Entity{pid: ^pid}, &1))

    new_state(%Location{state | exits: exits, contents: contents})
  end

  @doc """
  Called when a character exits.
  """
  defhandleinfo {:EXIT, pid, reason}, state: state = %Location{contents: contents} do
    IO.inspect "Trapped exit from #{inspect pid}, reason: #{inspect reason}"
    contents = Enum.reject(contents, &match?(%Entity{pid: ^pid}, &1))
    new_state(%Location{state | contents: contents})
  end

  # TODO: FIND OUT WHY CATCHALL is necessary here? Why do ways crash and notify the locations using :DOWN
  defhandleinfo _, do: noreply

  defcast remove_entity(pid), state: state do
    contents = Enum.reject(state.contents, &match?(%Entity{pid: ^pid}, &1))
    new_state(%Location{state | contents: contents})
  end

  defp add_incoming_ways(%Location{ways: ways, uuid: uuid}) do
    for %{entrance_uuid: entrance_uuid, name: name} <- ways do
      Alchemud.World.Way.start_link(%Way{entrance: entrance_uuid, exit: uuid, name: name })
    end
  end
end
