defmodule Alchemud.World.LocationManager do
  @moduledoc """
  manages:

    - loading of locations from persistence.
    - restarting of crashed locations.

  """

  def start_location(initial_state) do
    Alchemud.World.GenLocation.start_link(initial_state)
  end

  def start do
    load_from_persistent_storage
    |> Stream.map(&start_location/1)
    |> Stream.run
  end

  def whereis_location(uuid) do
    maybe_pid = :global.whereis_name {:location, uuid}
    case maybe_pid do
      :undefined  -> nil
      _           -> maybe_pid
    end
  end

  @doc """
  STUB
  """
  defp load_from_persistent_storage do
    [
      %{location_module: Alchemud.World.Location.Forest, name: "foo", uuid: "jkl", description: "foobar"},
      %{location_module: Alchemud.World.Location.Forest, name: "bar", uuid: "lkj", description: "barfoo"}
    ]
  end
end