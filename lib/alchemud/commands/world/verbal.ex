defmodule Alchemud.Commands.World.Verbal do

  @behaviour Alchemud.Commands.Behaviour

  alias Alchemud.World.Character
  alias Alchemud.Players.Player
  alias Alchemud.World.Way


  def maybe_consume_command(player, "say " <> message) do
    say(String.last(message), player, String.strip(message))
    true
  end

  def maybe_consume_command(player, "\"" <> message) do
    maybe_consume_command(player, "say " <> String.replace_suffix(message, "\"", ""))
  end

  def maybe_consume_command(player, "\'" <> message) do
    maybe_consume_command(player, "say " <> String.replace_suffix(message, "\'", ""))
  end

  def maybe_consume_command(player, "yell" <> message) do
    yell(player, String.strip(message))
    true
  end

  def maybe_consume_command(_, _) do
    nil
  end


  defp say("!", player, message) do
    Character.broadcast_from(player, ~s[#{player.name} exclaims: "#{message}"])
    Player.send_message(player, ~s[You exclaim: "#{message}"])
  end

  defp say("?", player, message) do
    Character.broadcast_from(player, ~s[#{player.name} asks: "#{message}"])
    Player.send_message(player, ~s[You ask: "#{message}"])
  end

  defp say(_, player, message) do
    Character.broadcast_from(player, ~s[#{player.name} says: "#{message}"])
    Player.send_message(player, ~s[You say: "#{message}"])
  end

  defp yell(player, message) do
    message = String.upcase(message)
    Character.broadcast_from(player, ~s[#{player.name} yells: "#{message}!"])
    Player.send_message(player, ~s[You yell: "#{message}!"])
  end
end