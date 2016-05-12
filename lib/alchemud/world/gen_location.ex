defmodule Alchemud.World.GenLocation do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  use ExActor.GenServer

  alias Alchemud.World.Way


  defstart start_link(initial_state = %{location_module: _, uuid: uuid}), gen_server_opts: [name: {:global, {:location, uuid}}] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)

    add_incoming_ways(initial_state)
    initial_state(initial_state)
  end

  defhandleinfo :tick, state: state = %{location_module: location_module} do
    new_state = location_module.handle_tick(state)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end

  defcall add_exit(pid, state) do
    IO.puts "Adding exit:"
    IO.inspect pid
    IO.inspect state
    Process.monitor(pid)
  end

  def add_incoming_ways(state = %{ways: ways, uuid: uuid}) do
    IO.puts "Adding incoming ways"
    IO.inspect ways
    for %{entrance_uuid: entrance_uuid, name: name} <- ways do
      Alchemud.World.GenWay.start_link(%Way{entrance: entrance_uuid, exit: uuid, name: name })
    end
  end
end