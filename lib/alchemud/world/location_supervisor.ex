defmodule Alchemud.World.LocationSupervisor do
  @moduledoc """
  Supervises locations.

  TODO: Find out how to restart locations when they are down.
  (with what parameters/state)
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Alchemud.World.Location, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_child(args) do
    Supervisor.start_child(__MODULE__, [args])
  end
end