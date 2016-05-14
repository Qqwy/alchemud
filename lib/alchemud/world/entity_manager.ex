defmodule Alchemud.World.EntityManager do
  @moduledoc """
  Handles
    - creating entities from persistent storage
    - restarting crashed entities.


  """
  alias Alchemud.World.Entity

  def start_entity(initial_state) do
    Alchemud.World.GenEntity.start(initial_state)
  end


  def start do
    load_from_persistent_storage
    |> Stream.map(&start_entity/1)
    |> Stream.run
  end

  def whereis_entity(uuid) do
    maybe_pid = :global.whereis_name {:entity, uuid}
    case maybe_pid do
      :undefined  -> nil
      _           -> maybe_pid
    end
  end

  @doc """
  STUB
  """
  def load_from_persistent_storage do
    [
      %Entity{module: Alchemud.World.Entity.Bird, name: "red bird",  uuid: "e1", container_uuid: "forest1"},
      %Entity{module: Alchemud.World.Entity.Bird, name: "grey bird", uuid: "e2", container_uuid: "forest1"},
      %Entity{module: Alchemud.World.Entity.Bird, name: "pink bird", uuid: "e3", container_uuid: "forest2"}
    ]
  end
end