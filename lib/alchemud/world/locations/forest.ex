defmodule Alchemud.World.Location.Forest do
  @moduledoc """
  A simple test location.
  """

  use Alchemud.World.Location.Behaviour

  def handle_tick(location = %{name: name}) do 
    #Location.broadcast(location.pid, [:font_1, "The trees swing softly in the breeze."])
    location
  end

  def location_category_name(location) do
    "forest"
  end
end