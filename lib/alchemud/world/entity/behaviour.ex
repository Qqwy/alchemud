defmodule Alchemud.World.Entity.Behaviour do
  @type entity_state_map :: %{entity_module: atom}

  @callback handle_tick(entity_state_map) :: entity_state_map

  def transient_fields, do: [:pid, :container_pid]
end