defmodule Alchemud.World.Entity.Bird do

  use Alchemud.World.Entity.Behaviour

  def handle_tick(state = %{name: name}) do
    IO.puts "IM BIRD #{name} AND I CANNOT LIE! I exist in: #{Alchemud.World.Entity.location_info(state).name}"
    state
  end

    def after_init(state, extra_opts) do
      state
    end
end
