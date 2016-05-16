defmodule Alchemud.World.Entity.Bird do

  @behaviour Alchemud.World.Entity

  def handle_tick(state = %{name: name}) do
    IO.puts "IM BIRD #{name} AND I CANNOT LIE! I exist in: #{Alchemud.World.GenEntity.location_info(state).name}"
    state
  end
end
