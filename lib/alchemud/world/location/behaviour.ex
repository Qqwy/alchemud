defmodule Alchemud.World.Location.Behaviour do
  @moduledoc """
  A single location in the game.

  Can be travelled to and from through any of the 'ways' between locations.
  """

  @type location_state_map :: %{location_module: atom}

  @callback handle_tick(location_state_map) :: location_state_map

  @callback location_description(location_state_map) :: iodata

  defmacro __using__(opts) do
    quote do
      require Alchemud.World.Location.Behaviour
      @behaviour Alchemud.World.Location.Behaviour

      def after_init(location_state, _extra_data) do
        # Nothing
        location_state
      end

      def handle_tick(location_state) do
        # Nothing
        location_state
      end

      def location_description(location_state) do
        [:cyan, :bright, location_state.name, "\r\n", :white, :normal, location_state.description]
      end

      defoverridable after_init: 2, handle_tick: 1, location_description: 1
    end
  end

end
