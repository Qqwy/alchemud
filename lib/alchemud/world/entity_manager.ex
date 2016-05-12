defmodule Alchemud.World.EntityManager do
  @moduledoc """
  Handles
    - creating entities from persistent storage
    - restarting crashed entities.


  """

  def start_entity(initial_state) do
    Alchemud.World.GenEntity.start_link(initial_state)
  end


  def start do
    load_from_persistent_storage
    |> Stream.map(&start_entity/1)
    |> Stream.run
  end

  def whereis_entity(uuid) do
    :global.whereis_name {:entity, uuid}
  end

  @doc """
  STUB
  """
  defp load_from_persistent_storage do
    [
      %{entity_module: Alchemud.World.Entity.Bird, name: "foo", uuid: "asdf"},
      %{entity_module: Alchemud.World.Entity.Bird, name: "bar", uuid: "fdsa"}
    ]
  end
end