defmodule Alchemud.Commands.World do
  @vehaviour Alchemud.Commands.Behaviour
  @moduledoc """
  Handles listening to world-based commands.
  These are usually actions the player can do inside the world.

  Dispatches to the player object/location, which might have more implementations of specific command-handlers.
  """

  alias Alchemud.World.Character

  def maybe_consume_command(player, "look") do
    Character.look_at_location(player)
  end  

  def maybe_consume_command(player, "exits") do
    Character.list_exits(player)
  end

  def maybe_consume_command(_player, _command) do
    nil
  end
end