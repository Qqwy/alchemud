defmodule Alchemud.World.Entity.Behaviour do
  alias Alchemud.World.Entity

  @callback after_init(Entity.t, []) :: Entity.t
  @callback handle_tick(Entity.t) :: Entity.t
  @callback glance_description(Entity.t) :: iodata

  def transient_fields, do: [:pid, :container_pid]

  defmacro __using__(opts) do
    quote do
      require Alchemud.World.Entity.Behaviour
      @behaviour Alchemud.World.Entity.Behaviour

      def after_init(entity, _extra_data) do
        # Nothing
        entity
      end

      def handle_tick(entity) do
        # Nothing
        entity
      end

      def glance_description(entity) do
        "#{entity.name} is here"
      end

      defoverridable after_init: 2, handle_tick: 1, glance_description: 1
    end
  end
end