defmodule Alchemud.Commands do
  @moduledoc """
  Handles command parsing (binary strings that players send to influence the world)
  """

  alias Alchemud.Commands.{Universal, World}
  alias Alchemud.Connections.Connection

  @do_not_understand_messages [
    "Can you restate that?",
    "Umm, what?",
    "I do not understand."
  ]


  
  @doc """
  Consumes the command by trying to match it against:

  - Alchemud.Commands.Universal.maybe_consume_command
  - Alchemud.Commands.World.maybe_consume_command

  if nothing found, will itself consume the command, and print an 'I do not understand' message to the player.
  """

  @doc """
  Removes any non-printing-characters from the command,  (TODO)
  as well as starting/trailing whitespace.
  
  """
  def prettify_command(command) do
    command
    |> String.strip
  end

  def consume_command(connection, command) do
    command = prettify_command(command)
    Universal.maybe_consume_command(connection, command)
    || World.maybe_consume_command(connection, command)
    || print_do_not_understand_message(connection, command)
  end

  def print_do_not_understand_message(connection, _command) do
    message = @do_not_understand_messages |> Enum.random
    Connection.send_message(connection, message)
    true
  end
end