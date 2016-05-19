defmodule Alchemud.World.Location.Behaviour do
    @moduledoc """
  This is the behaviour that ought to be implemented by any locations.

  These to-be implemented functions are callbacks that are called from the `Location` GenServer, whenever applicable.

  Default implementations for these callbacks have been provided, so you only need to override the ones that are special for that entity.
  """

  alias Alchemud.World.Location

  @type location_state_map :: %{location_module: atom}

  @callback after_init(Location.t, any) :: Location.t

  @callback handle_tick(Location.t) :: Location.t

  @callback location_description(Location.t) :: iodata

  defmacro __using__(opts) do
    quote do
      alias Alchemud.World.Location
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
        [:cyan, :bright, location.name, [:white, :normal, " (", location_category_name(location) ,")"], "\r\n", :white, :normal, location.description]
      end

      def location_category_name(location) do
        "outdoors"
      end

      defoverridable after_init: 2, handle_tick: 1, location_description: 1, location_category_name: 1
    end
  end
end
