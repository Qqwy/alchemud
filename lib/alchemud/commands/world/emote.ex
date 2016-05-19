defmodule Alchemud.Commands.World.Emote do
  @moduledoc """
  Commands that have to do with expressing (emoting) things:

  - Saying things (Maybe these will be moved to their own module at some time)
  - mannerisms
  """

  alias Alchemud.World.Character
  alias Alchemud.Players.Player
  alias Alchemud.World.Way

  def maybe_consume_command(player, "me " <> emote) do
    Character.broadcast(player, "* #{player.name} #{emote}")
    Player.send_message(player, "* #{player.name} #{emote}")
  end

  def maybe_consume_command(player, "say " <> message) do
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
    maybe_consume_command(player, "say " <> String.replace_suffix(message, "\"", ""))
  end

  def maybe_consume_command(player, "\'" <> message) do
    maybe_consume_command(player, "say " <> String.replace_suffix(message, "\'", ""))
  end

  def maybe_consume_command(_, _) do
    nil
  end


  def say(player, message) do
    Character.broadcast(player, ~s[#{player.name} says: "#{message}"])
    Player.send_message(player, ~s[You say: "#{message}"])
  end

  def exclaim(player, message) do
    Character.broadcast(player, ~s[#{player.name} exclaims: "#{message}"])
    Player.send_message(player, ~s[You exclaim: "#{message}"])
  end

  def ask(player, message) do
    Character.broadcast(player, ~s[#{player.name} asks: "#{message}"])
    Player.send_message(player, ~s[You ask: "#{message}"])
  end
end