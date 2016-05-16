defmodule Alchemud.World.Location.Behaviour do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  @type location_state_map :: %{location_module: atom}

  @callback handle_tick(location_state_map) :: location_state_map

end
