defmodule Alchemud.World.Entity.Behaviour do
  @type entity_state_map :: %{entity_module: atom}

  @callback after_init(entity_state_map, []) :: entity_state_map
  @callback handle_tick(entity_state_map) :: entity_state_map
  @callback glance_description(entity_state_map) :: iodata

  def transient_fields, do: [:pid, :container_pid]

  defmacro __using__(opts) do
    quote do
      require Alchemud.World.Entity.Behaviour
      @behaviour Alchemud.World.Entity.Behaviour

      def after_init(entity_state, _extra_data) do
        # Nothing
        entity_state
      end

      def handle_tick(entity_state) do
        # Nothing
        entity_state
      end

      def glance_description(entity_state) do
        "#{entity_state.name} is here"
      end

      defoverridable after_init: 2, handle_tick: 1, glance_description: 1
    end
  end
end