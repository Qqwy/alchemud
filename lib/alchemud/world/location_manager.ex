defmodule Alchemud.World.LocationManager do
  @moduledoc """
  manages:

    - loading of locations from persistence.
    - restarting of crashed locations.

  """
  alias Alchemud.World.Location

  def start_location(initial_state) do
    Alchemud.World.GenLocation.start(initial_state)
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

  def whereis_way(entrance_location, exit_location, name) do
    maybe_pid = :global.whereis_name {:way, {entrance_location, exit_location, name}}
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
      %Location{module: Alchemud.World.Location.Forest, name: "foo", uuid: "forest1", description: "foobar", ways: [
        %{entrance_uuid: "forest2", name: "south"}
        ], exits: []
      },
      %Location{module: Alchemud.World.Location.Forest, name: "bar", uuid: "forest2", description: "barfoo", ways: [
        %{entrance_uuid: "forest1", name: "north"},
        %{entrance_uuid: "forest1", name: "south"}
        #,%{entrance_uuid: "unexistent", name: "unexistent"}
        ], exits: []
      }
    ]
  end
end