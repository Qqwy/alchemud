defmodule Alchemud.World do
  @moduledoc """
  Manages
    - things that happen everywhere in the world
  """
  alias Alchemud.World.{LocationManager, EntityManager}

  use ExActor.GenServer

  @tick_interval 100

  def tick_interval, do: @tick_interval

  defstart start_link do
    LocationManager.start
    EntityManager.start
    initial_state(:i_am_happy_and_you_know_it)
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
  def dg(uuid) do
    loc = LocationManager.whereis_location(uuid)
    if loc do
      loc |> Alchemud.World.Location.get
    else
      entity = EntityManager.whereis_entity(uuid)
      if entity do
        entity |> Alchemud.World.Entity.get
      else
        nil
      end
    end
  end
end
