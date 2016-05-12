defmodule Alchemud.World.GenLocation do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  use ExActor.GenServer

  alias Alchemud.World.Way
  alias Alchemud.World.Location


  defstart start(initial_state = %Location{module: _, uuid: uuid}), gen_server_opts: [name: {:global, {:location, uuid}}] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)

    add_incoming_ways(initial_state)
    initial_state(initial_state)
  end

  defcall get, state: state, do: reply(state) 
  defcall exits, state: %Location{exits: exits}, do: reply(exits) 

  defhandleinfo :tick, state: state = %Location{module: location_module} do
    new_state = location_module.handle_tick(state)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end

  # TODO: FIND OUT WHY CATCHALL is necessary here? Why do ways crash and notify the locations using :DOWN
  defhandleinfo _, do: noreply


  defcast add_exit(pid, way = %Way{name: exit_name}), state: state = %Location{ways: ways, exits: exits} do
    IO.puts "Adding exit:"
    IO.inspect pid
    IO.inspect way
    IO.inspect state
    Process.monitor(pid)
    new_state(%{state | exits: [way | exits]})
  end

  def add_incoming_ways(state = %Location{ways: ways, uuid: uuid}) do
    IO.puts "Adding incoming ways"
    IO.inspect ways
    for %{entrance_uuid: entrance_uuid, name: name} <- ways do
      Alchemud.World.GenWay.start_link(%Way{entrance: entrance_uuid, exit: uuid, name: name })
    end
  end
end