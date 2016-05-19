defmodule Alchemud.World.Entity.Behaviour do
  @moduledoc """
  This is the behaviour that ought to be implemented by any entities.

  These to-be implemented functions are callbacks that are called from the `Entity` GenServer, whenever applicable.

  Default implementations for these callbacks have been provided, so you only need to override the ones that are special for that entity.
  """

  alias Alchemud.World.Entity

  @callback after_init(Entity.t, []) :: Entity.t
  @callback handle_tick(Entity.t) :: Entity.t
  @callback glance_description(Entity.t) :: iodata

  def transient_fields, do: [:pid, :container_pid]

  defmacro __using__(opts) do
    quote do
      alias Alchemud.World.Entity
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

      def receive_broadcast(entity, broadcaster, message) do
        # Nothing
        entity
      end

      defoverridable after_init: 2, handle_tick: 1, glance_description: 1, receive_broadcast: 3
    end
  end
end