defmodule Alchemud.Commands do
  @moduledoc """
  Handles command parsing (binary strings that players send to influence the world)
  """

  alias Alchemud.Commands.{Universal, World}

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

  def consume_command(player, command) do
    command = prettify_command(command)
    Universal.maybe_consume_command(player, command)
    || World.maybe_consume_command(player, command)
    || print_do_not_understand_message(player, command)
  end

  def print_do_not_understand_message(player, _command) do
    message = @do_not_understand_messages |> Enum.random
    Alchemud.Connections.Telnet.Handler.send_message(player, message)
    true
  end
end