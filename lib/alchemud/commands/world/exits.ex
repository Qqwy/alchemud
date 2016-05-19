defmodule Alchemud.Commands.World.Exits do
  @moduledoc """
  Checks if the player attempts to move in one of the available directions (AKA ways AKA exits from the current location).

  If a known exit name is used that is not an exit of the current room, an error message is print.
  """

  alias Alchemud.World.Character
  alias Alchemud.Players.Player
  alias Alchemud.World.Way

  @common_exits_with_aliases %{
    "north" => "n", 
    "south" => "s", 
    "east" => "e", 
    "west" => "w", 
    "up" => "u", 
    "down" => "d", 
    "in" => "in", 
    "out" => "out"
  }

  def maybe_consume_command(player, command) do
    exits = Character.exits(player)
    matched_exit = Enum.find(exits, &way_referenced_by_exit_name?(&1, command))
    if matched_exit do
      Character.move_across_exit(player, matched_exit)
      true
    else
      if command in common_exit_names do
        Player.send_message(player, "There is no exit in that direction.")
        true
      else
        nil
      end
    end
  end

  def common_exit_names do
    Map.keys(@common_exits_with_aliases) ++ Map.values(@common_exits_with_aliases)
  end

  def way_referenced_by_exit_name?(%Way{name: exit_name}, exit_name), do: true
  def way_referenced_by_exit_name?(%Way{name: name}, exit_name) do
    @common_exits_with_aliases[name] == exit_name
  end



end