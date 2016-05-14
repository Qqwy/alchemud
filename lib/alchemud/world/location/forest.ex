defmodule Alchemud.World.Location.Forest do
  #@behaviour Alchemud.Wold.Location
  use ExActor.GenServer
  use Alchemud.World.Location

  def handle_tick(state = %{name: name}) do 
    IO.puts "#{name}: The trees swing softly in the breeze."
    state
  end
end