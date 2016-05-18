defmodule Alchemud.Commands.World.Emote do
  alias Alchemud.World.Character
  alias Alchemud.Players.Player
  alias Alchemud.World.Way

  def maybe_consume_command(player, "me "<> emote) do
    Player.send_message(player, "* #{player.name} #{emote}")
  end

  def maybe_consume_command(player, "say "<> message) do
    # TODO: Message to others
    cond do
      String.ends_with?(message, "!") ->
        exclaim(player, message)
      String.ends_with?(message, "?") ->
        ask(player, message)
      true ->
        say(player, message)
        
    end
   
  end

  def maybe_consume_command(player, "\"" <> message) do
    maybe_consume_command(player, "say "<> String.replace_suffix(message, "\"", ""))
  end

  def maybe_consume_command(player, "\'" <> message) do
    maybe_consume_command(player, "say "<> String.replace_suffix(message, "\'", ""))
  end

  def maybe_consume_command(_, _) do
    nil
  end


  def say(player, message) do
    Player.send_message(player, "You say: #{message}")
  end

  def exclaim(player, message) do
    Player.send_message(player, "You exclaim: #{message}")
  end

  def ask(player, message) do
    Player.send_message(player, "You ask: #{message}")
  end
end