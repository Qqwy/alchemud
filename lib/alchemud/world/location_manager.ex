defmodule Alchemud.World.LocationManager do
  @moduledoc """
  manages:

    - loading of locations from persistence.
    - restarting of crashed locations.

  """

  def start_location(location_module, description) do
    Alchemud.World.GenLocation.start_link(location_module, description)
  end
end