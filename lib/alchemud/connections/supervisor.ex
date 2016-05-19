defmodule Alchemud.Connections.Supervisor do
  @moduledoc """
  Supervises all different kinds of Connection Listeners.

  (Telnet, ???, ???, etc)
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Alchemud.Connections.Telnet.Listener,[])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
