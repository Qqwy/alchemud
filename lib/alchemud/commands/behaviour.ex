defmodule Alchemud.Commands.Behaviour do
  # TODO: Find out what to actually pass here as player, instead of a `socket`.
  @type player :: any
  @type command :: binary

  @doc """
  An implementation should return `nil` if the command could not be consumed
  And otherwise return `true`.
  """
  @callback maybe_consume_command(player, command) :: nil | true
end