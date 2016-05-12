defmodule Alchemud.World.Entity do
  @type entity_state_map :: %{entity_module: atom}

  @callback handle_tick(entity_state_map) :: entity_state_map
end