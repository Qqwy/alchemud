defmodule Alchemud.World do
  @moduledoc """
  Manages
    - things that happen everywhere in the world
  """
  alias Alchemud.World.{LocationManager, EntityManager}

  @tick_interval 10000

  def tick_interval, do: @tick_interval

  def start do
    LocationManager.start
    EntityManager.start
  end

  @doc """
  SHOULD BE USED FOR DEBUGGING PURPOSES ONLY!
  """
  def whereis(uuid) do
    LocationManager.whereis_location(uuid) || EntityManager.whereis_entity(uuid)
  end

  @doc """
  SHOULD BE USED FOR DEBUGGING PURPOSES ONLY!
  """
  def debug_get(uuid) do
    loc = LocationManager.whereis_location(uuid)
    if loc do
      loc |> Alchemud.World.GenLocation.get
    else
      entity = EntityManager.whereis_entity(uuid)
      if entity do
        entity |> Alchemud.World.GenEntity.get
      else
        nil
      end
    end
  end
end
