defmodule Alchemud.Commands do
  @moduledoc """
  Handles command parsing (binary strings that players send to influence the world)
  """
  use Logger

  alias Alchemud.Commands.{Service, Universal, World}
  alias Alchemud.Players.Player

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


  def consume_command(player, command) do
    try do
      Service.maybe_consume_command(player, command)
      || Universal.maybe_consume_command(player, command)
      || World.maybe_consume_command(player, command)
      || print_do_not_understand_message(player, command)
    rescue e ->
      Logger.error "ERROR ENCOUNTERED: \r\n#{inspect e}"#\r\n\r\n #{inspect stacktrace}\r\n\r\n"
      print_do_not_understand_message(player, command)
    end
  end

  def print_do_not_understand_message(player, _command) do
    message = @do_not_understand_messages |> Enum.random
    Player.send_message(player, message)
    true
  end
end