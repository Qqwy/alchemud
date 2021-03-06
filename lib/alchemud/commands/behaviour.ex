defmodule Alchemud.Commands.Behaviour do
  @moduledoc """
  Anything that can consume commands should adhere to this Behaviour.
  """

  @type player :: %Alchemud.Players.Player{}
  @type command :: binary

  @doc """
  An implementation should return `nil` if the command could not be consumed
  And otherwise return `true`.
  """
  @callback maybe_consume_command(player, command) :: nil | true
end