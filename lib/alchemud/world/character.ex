defmodule Alchemud.World.Character do
  alias Alchemud.Players.Player
  alias Alchemud.World.Entity
  alias Alchemud.World.Location
  alias Alchemud.World.Way

  @behaviour Alchemud.World.Entity.Behaviour


  def handle_tick(entity_state_map) do
    IO.puts "I AM HERE"
    entity_state_map
  end

  def start(player) do
    player
    |> load_character_info
    |> Alchemud.World.Entity.start
  end


  def load_character_info(player = %Player{}) do
    # TODO: Load from some kind of persistence.
    
    %Entity{module: __MODULE__, name: player.name, description: "THIS IS A Character :D", container_uuid: "forest1", uuid: player.name}
    |> Apex.ap
  end

  def look_at_location(player = %Player{}) do
    location_pid = Entity.get_location_pid(player.character)
    location_info = Location.get(location_pid)
    Player.send_message(player, [:cyan, :bright, location_info.name, "\r\n\r\n", :white, location_info.description])
  end

  def list_exits(player = %Player{}) do
    exits = Entity.get_location_pid(player.character)
    |> Location.exits
    |> Enum.map(fn %Way{name: name} -> name end)
    |> Enum.join(", ")
    Player.send_message(player, ["you see exits leading to the: ", :blue, exits])
  end

  def shutdown(_player) do
    exit(:shutdown)
  end
end