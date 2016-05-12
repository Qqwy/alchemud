defmodule Alchemud.World.GenLocation do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  use ExActor.GenServer

  defstart start_link(initial_state = %{location_module: _, uuid: uuid}), gen_server_opts: [name: {:global, {:location, uuid}}] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    initial_state(initial_state)
  end

  defhandleinfo :tick, state: state = %{location_module: location_module} do
    new_state = location_module.handle_tick(state)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end
end