defmodule Alchemud.World.GenLocation do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  use ExActor.GenServer

  alias Alchemud.World.{Location, Way, Entity}


  defstart start_link(initial_state = %Location{module: _, uuid: uuid}), gen_server_opts: [name: {:global, {:location, uuid}}] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)

    add_incoming_ways(initial_state)
    initial_state(initial_state)
  end

  defcall get, state: state, do: reply(state) 

  @doc """
  Lists all Ways that are exits from this location.
  """ 
  defcall exits, state: %Location{exits: exits}, do: reply(exits) 


  @doc """
  Adds a Way to the list of tis Location's exits.
  TODO: Find out if storing Way's PID is better than storing its UUID.
  """
  defcast add_exit(way_pid, way = %Way{name: exit_name}), state: state = %Location{ways: ways, exits: exits} do
    IO.puts "Adding exit:"
    IO.inspect way_pid
    IO.inspect way
    IO.inspect state
    Process.monitor(way_pid)
    new_state(%Location{state | exits: [%Way{way | pid: way_pid} | exits]})
  end

  @doc """
  When adding an entity, we add a reference to the PID.
  Entities are themselves responsible to save pointers to their locations/containers.
  As the state of the entity might (rapidly!) change, this state is not sent over.
  """
  defcall add_entity(entity_pid, entity = %Entity{}), state: state = %Location{contents: contents} do
    IO.puts "Adding entity:"
    IO.inspect entity_pid
    IO.inspect entity
    IO.inspect state
    Process.monitor(entity_pid)
    new_state(%Location{state | contents: [%Entity{entity | pid: entity_pid} | contents]})
    reply(:ok)
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
    IO.inspect [ref, pid, reason]

    # Filter exits
    exits = Enum.reject(exits, fn %Way{pid: way_pid} -> pid == way_pid end)
    # TODO: Filter contents?
    contents = Enum.reject(contents, fn %Entity{pid: entity_pid} -> pid == entity_pid end)

    new_state(%Location{state | exits: exits, contents: contents})
  end

  # TODO: FIND OUT WHY CATCHALL is necessary here? Why do ways crash and notify the locations using :DOWN
  defhandleinfo _, do: noreply

  defp add_incoming_ways(state = %Location{ways: ways, uuid: uuid}) do
    IO.puts "Adding incoming ways"
    IO.inspect ways
    for %{entrance_uuid: entrance_uuid, name: name} <- ways do
      Alchemud.World.GenWay.start_link(%Way{entrance: entrance_uuid, exit: uuid, name: name })
    end
  end
end
