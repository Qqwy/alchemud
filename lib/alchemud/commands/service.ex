defmodule Alchemud.Commands.Service do
  @behaviour Alchemud.Commands.Behaviour
  @moduledoc """
  Servicecommands that have to do with the connection.
  Most importantly: Exiting.
  """

  alias Alchemud.Connections.Connection

  def maybe_consume_command(player, msg) when msg in ["exit", "quit"] do
    Connection.close(player)
    true
  end

  def maybe_consume_command(player, _) do
    nil
  end
end