defmodule Alchemud.World.Entity.Bird do

  @behaviour Alchemud.World.Entity

  def handle_tick(state = %{name: name}) do
    IO.puts "IM BIRD #{name} AND I CANNOT LIE!"
    state
  end
end