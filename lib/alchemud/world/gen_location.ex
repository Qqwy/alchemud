defmodule Alchemud.World.GenLocation do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  use ExActor.GenServer

  defstart start_link(location_module, description \\ "") do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)

    initial_state(%{location_module: location_module, description: description})

  end

  defhandleinfo :tick, state: state = %{location_module: location_module} do
    new_state = location_module.handle_tick(state)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end
end