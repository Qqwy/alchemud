defmodule Alchemud.Commands.World.Emote do
  @moduledoc """
  Commands that have to do with expressing (emoting) things:

  - Saying things (Maybe these will be moved to their own module at some time)
  - mannerisms
  """
  @behaviour Alchemud.Commands.Behaviour

  alias Alchemud.World.Character
  alias Alchemud.Players.Player
  alias Alchemud.World.Way

  def maybe_consume_command(player, "me " <> emote) do
    Character.broadcast_from(player, "* #{player.name} #{emote}")
    Player.send_message(player, "* #{player.name} #{emote}")
  end

  def maybe_consume_command(_, _) do
    nil
  end
end
