defmodule Alchemud.World.Entity do
  @type entity_state_map :: %{entity_module: atom}

  @callback handle_tick(entity_state_map) :: entity_state_map

  defstruct module: nil, uuid: nil, container_uuid: nil, container_pid: nil, name: "", description: "", state: nil, pid: nil
  def transient_fields, do: [:pid, :container_pid]
end