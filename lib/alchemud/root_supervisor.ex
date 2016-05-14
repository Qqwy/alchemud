defmodule Alchemud.RootSupervisor do
  @moduledoc """
  Supervises all parts:

    - World
    - EntityManager
    - ConnectionManager
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = []
    supervise(children, strategy: :one_for_one)
  end
end