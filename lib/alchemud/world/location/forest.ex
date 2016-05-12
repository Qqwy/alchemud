defmodule Alchemud.World.Location.Forest do
  @behaviour Alchemud.Wold.Location

  def handle_tick(state) do 
    IO.puts "The trees swing softly in the breeze."
    state
  end
end