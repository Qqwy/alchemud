defmodule Alchemud.World.Supervisor do
  @moduledoc """
  Supervises:
  - global World processes
  - LocationSupervisor
  - ???
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Alchemud.World.LocationSupervisor,[])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
