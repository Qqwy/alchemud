defmodule Alchemud.Commands.Universal do
  @behaviour Alchemud.Commands.Behaviour
  @moduledoc """
  Commands that can be done from everywhere.
  Things like changing the options, consulting 'help', or participating in the global chat.
  """

  def maybe_consume_command(player, "hello") do
    Alchemud.Players.Player.send_message(player, "Hello to you too!")
    true
  end

  def maybe_consume_command(_player, _command) do
    nil
  end
end