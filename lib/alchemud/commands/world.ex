defmodule Alchemud.Commands.World do
  @vehaviour Alchemud.Commands.Behaviour
  @moduledoc """
  Handles listening to world-based commands.
  These are usually actions the player can do inside the world.

  Dispatches to the player object/location, which might have more implementations of specific command-handlers.
  """

  alias Alchemud.World.Character

  def maybe_consume_command(player, command) when command in ["look", "l"] do
    Character.look_at_location(player)
  end  

  def maybe_consume_command(player, command) when command in ["exits", "x"] do
    Character.list_exits(player)
  end

  def maybe_consume_command(player, command) do
    Alchemud.Commands.World.Exits.maybe_consume_command(player, command)
    || Alchemud.Commands.World.Verbal.maybe_consume_command(player, command)
    || Alchemud.Commands.World.Emote.maybe_consume_command(player, command)
    || nil
  end
end