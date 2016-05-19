defmodule Alchemud.World.Location.Forest do
  use Alchemud.World.Location.Behaviour

  def handle_tick(state = %{name: name}) do 
    IO.puts "#{name}: The trees swing softly in the breeze."
    state
  end
end