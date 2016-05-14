defmodule Alchemud.World.LocationSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Alchemud.World.GenLocation, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_child(args) do
    IO.inspect args
    Supervisor.start_child(__MODULE__, [args])
  end
end