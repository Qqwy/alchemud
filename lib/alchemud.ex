defmodule Alchemud do
  @moduledoc """
  A bare-bones Multi-User-Dungeon implementation in Elixir.
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Alchemud.Worker, [arg1, arg2, arg3]),
      supervisor(Alchemud.World.Supervisor,[]),
      supervisor(Alchemud.Connections.Supervisor,[]),
      worker(Alchemud.World, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Alchemud.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
