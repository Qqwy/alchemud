defmodule Alchemud.Commands.World do
  @vehaviour Alchemud.Commands.Behaviour
  @moduledoc """
  Handles listening to world-based commands.
  These are usually actions the player can do inside the world.

  Dispatches to the player object/location, which might have more implementations of specific command-handlers.
  """

  alias Alchemud.Players.Player

  def maybe_consume_command(player, "look") do
    Player.look_at_location(player)
  end  

  def maybe_consume_command(player, "exits") do
    Player.list_exits(player)
  end 

  def maybe_consume_command(_player, _command) do
    nil
  end
end