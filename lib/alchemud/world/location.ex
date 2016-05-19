defmodule Alchemud.World.Location do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  defstruct module: nil, uuid: nil, description: "", name: "", ways: [], exits: [], contents: [], pid: nil
  def transient_fields, do: [:exits, :contents, :pid]
  alias Alchemud.World.Location  

  use ExActor.GenServer

  require Logger

  alias Alchemud.World.{Way, Entity}


  defstart start_link(location = %Location{}), gen_server_opts: [name: process_name(location)] do
    location = %Location{location | pid: self}
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    Process.flag(:trap_exit, true) # Trap Entity exits.

    add_incoming_ways(location)
    initial_state(location)
  end

  def process_name(%Location{uuid: uuid}) do
    {:global, {:location, uuid}}
  end

  defcall get, state: location, do: reply(location) 

  defcall get_description, state: location do 
    location
    |> location.module.location_description
    |> reply
  end

  defcall get_contents, state: location, do: reply(location.contents) 

  @doc """
  Lists all Ways that are exits from this location.
  """ 
  defcall exits, state: location, do: reply(location.exits) 

 
  @doc """
  Adds a Way to the list of tis Location's exits.
  TODO: Find out if storing Way's PID is better than storing its UUID.
  """
  defcall add_exit(way_pid, way = %Way{}), state: location do
    Process.monitor(way_pid)
    location = %Location{location | exits: [%Way{way | pid: way_pid} | location.exits]}
    set_and_reply(location, :ok)
  end

  @doc """
  When adding an entity, we add a reference to the PID.
  Entities are themselves responsible to save pointers to their locations/containers.
  As the state of the entity might (rapidly!) change, this state is not sent over.
  """
  defcall add_entity(entity_pid, entity = %Entity{}), state: location do
    Process.link(entity_pid)
    location = %Location{location | contents: [%Entity{entity | pid: entity_pid} | location.contents]}
    set_and_reply(location, :ok)
  end

  @doc """
  Broadcasts a message to all other entities in this location.
  `broadcaster` should be the PID of the sender.
  `message` should be an iodata message.
  """
  defcast broadcast(broadcaster, message), state: location do
    location.contents
    |> Enum.reject(&match?(%Entity{pid: ^broadcaster}, &1))
    |> Enum.each(fn entity -> Entity.receive_broadcast_from_location(entity.pid, broadcaster, message) end)
    noreply
  end

  @doc """
  Shorthand for a location itself broadcasting something.
  """
  def broadcast(pid, message) do
    Location.broadcast(pid, pid, message)
  end

  @doc """
  Called internally when time has passed.
  """
  defhandleinfo :tick, state: location do
    location = location.module.handle_tick(location)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(location)
  end

  @doc """
  - Removes exit(ways) that are down from the `exits` list.
  - Removes entities that are down from the `contents` list.
  """
  defhandleinfo {:DOWN, ref, :process, pid, reason}, state: location do
    Logger.debug "[#{inspect self}]:DOWN message received:"
    Apex.ap [ref, pid, reason]

    # Filter exits
    exits = Enum.reject(location.exits, &match?(%Way{pid: ^pid}, &1))
    # Filter contents
    contents = Enum.reject(location.contents, &match?(%Entity{pid: ^pid}, &1))

    new_state(%Location{location | exits: exits, contents: contents})
  end

  @doc """
  Called when a character exits.
  """
  defhandleinfo {:EXIT, pid, reason}, state: location do
    Logger.debug "Trapped exit from #{inspect pid}, reason: #{inspect reason}"
    contents = Enum.reject(location.contents, &match?(%Entity{pid: ^pid}, &1))
    new_state(%Location{location | contents: contents})
  end

  # TODO: FIND OUT WHY CATCHALL is necessary here? Why do ways crash and notify the locations using :DOWN
  defhandleinfo _, do: noreply

  defcast remove_entity(pid), state: location do
    contents = Enum.reject(location.contents, &match?(%Entity{pid: ^pid}, &1))
    new_state(%Location{location | contents: contents})
  end

  defp add_incoming_ways(%Location{ways: ways, uuid: uuid}) do
    for %{entrance_uuid: entrance_uuid, name: name} <- ways do
      Alchemud.World.Way.start_link(%Way{entrance: entrance_uuid, exit: uuid, name: name})
    end
  end
end
