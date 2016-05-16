defmodule Alchemud.World.Character do
  alias Alchemud.Players.Player
  alias Alchemud.World.Entity

  @behaviour Alchemud.World.Entity.Behaviour


  def handle_tick(entity_state_map) do
    IO.puts "I AM HERE"
    entity_state_map
  end

  def start_link(player) do
    player
    |> load_character_info
    |> Alchemud.World.Entity.start_link
  end


  def load_character_info(player = %Player{}) do
    # TODO: Load from some kind of persistence.
    
    %Entity{module: __MODULE__, name: player.name, description: "THIS IS A Character :D", container_uuid: "forest1", uuid: player.name}
    |> Apex.ap
  end

  def look_at_location(player = %Player{character: character}) do
    location_info = Entity.get_location_info(character)
    Player.send_message(player, [:red, location_info.name, "\r\n\r\n", :white, location_info.description])
  end
end