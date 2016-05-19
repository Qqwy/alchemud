defmodule Alchemud.World.LocationManager do
  @moduledoc """
  manages:

    - loading of locations from persistence.
    - restarting of crashed locations.

  """
  alias Alchemud.World.Location

  def start_location(initial_state) do
    Alchemud.World.LocationSupervisor.start_child(initial_state)
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

  # STUB
  defp load_from_persistent_storage do
    [
      %Location{module: Alchemud.World.Location.Forest, name: "The small forest path", uuid: "forest1", description: "This small path in the forest, frequented by animals.\r\nIt stops in the bushes at the north, but is clearly defined to the south.\r\nSmall bushes hang overhead.", ways: [
        %{entrance_uuid: "forest2", name: "south"}
        ], exits: []
      },
      %Location{module: Alchemud.World.Location.Forest, name: "A muddy pond", uuid: "forest2", description: "At the side of the path, that curves from north to east here,\r\nis a small dark and muddy pond.\r\nIt is mostly dried out right now.", ways: [
        %{entrance_uuid: "forest1", name: "north"},
        %{entrance_uuid: "forest3", name: "east"}
        #,%{entrance_uuid: "unexistent", name: "unexistent"}
        ], exits: []
      },
      %Location{module: Alchemud.World.Location.Forest, name: "The darker foresty path", uuid: "forest3", description: "The trees alongside the path are a lot taller here.\r\nTo the west, you can see the path make a small curve.\r\nIn all other directions, the path seems to have stopped.", ways: [
        %{entrance_uuid: "forest2", name: "west"}
        ], exits: []
      },
    ]
  end
end