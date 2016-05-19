defmodule Alchemud.World.Character do
  alias Alchemud.Players.Player
  alias Alchemud.World.Entity
  alias Alchemud.World.Location
  alias Alchemud.World.Way

  use Alchemud.World.Entity.Behaviour


  def handle_tick(entity_state_map) do
    IO.puts "I AM HERE"
    entity_state_map
  end

  def start(player) do
    player
    |> load_character_info
    |> Alchemud.World.Entity.start(player)
  end

  def after_init(character_data, player) do
    character_data
  end

  def load_character_info(player = %Player{}) do
    # TODO: Load from some kind of persistence.
    
    %Entity{module: __MODULE__, name: player.name, description: "THIS IS A Character :D", container_uuid: "forest1", uuid: player.name}
  end

  def look_at_location(player = %Player{}) do
    location_pid = Entity.get_location_pid(player.character)
    #location_info = Location.get(location_pid)
    #Player.send_message(player, [:cyan, :bright, location_info.name, "\r\n", :white, :normal, location_info.description])
    Player.send_message(player, Location.get_description(location_pid))

    list_location_contents(player, location_pid)

    list_exits(player)
    Player.send_message(player, "")
  end

  def list_location_contents(player, location_pid) do
    character_pid = player.character
    content_names = Location.get_contents(location_pid)
    |> Enum.reject(&match?(%Entity{pid: ^character_pid}, &1))
    |> Enum.map(fn %Entity{name: name} -> name end)
    if length(content_names) > 0 do
      Player.send_message(player, ["The following is/are here: ", :yellow, content_names])
    end
  end

  def list_exits(player = %Player{}) do
    exit_names = exits(player)
    |> Enum.map(fn %Way{name: name} -> 
      name 
      |> Alchemud.Humanize.underline 
    end)
    |> Alchemud.Humanize.enum
    Player.send_message(player, [:green, :bright, "you see exits leading to the ", exit_names])
  end

  def exits(player = %Player{}) do
    Entity.get_location_pid(player.character)
    |> Location.exits
  end

  def move_across_exit(player = %Player{}, way = %Way{}) do
    # TODO: Messages to others.
    Player.send_message(player, "You move #{way.name}. \r\n")
    Entity.move_to(player.character, way.exit)
    look_at_location(player)
  end

  def shutdown(_player) do
    exit(:shutdown)
  end
end