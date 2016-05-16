defmodule Alchemud.World.Entity.Bird do

  @behaviour Alchemud.World.Entity.Behaviour

  def handle_tick(state = %{name: name}) do
    IO.puts "IM BIRD #{name} AND I CANNOT LIE! I exist in: #{Alchemud.World.Entity.location_info(state).name}"
    state
  end
end