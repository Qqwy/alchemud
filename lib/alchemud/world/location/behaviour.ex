defmodule Alchemud.World.Location.Behaviour do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """
  alias Alchemud.World.Location

  @type location_state_map :: %{location_module: atom}

  @callback after_init(Location.t, any) :: Location.t

  @callback handle_tick(Location.t) :: Location.t

  @callback location_description(Location.t) :: iodata

  defmacro __using__(opts) do
    quote do
      require Alchemud.World.Location.Behaviour
      @behaviour Alchemud.World.Location.Behaviour

      def after_init(location, _extra_data) do
        # Nothing
        location
      end

      def handle_tick(location) do
        # Nothing
        location
      end

      def location_description(location) do
        [:cyan, :bright, location.name, "\r\n", :white, :normal, location.description]
      end

      defoverridable after_init: 2, handle_tick: 1, location_description: 1
    end
  end
end
