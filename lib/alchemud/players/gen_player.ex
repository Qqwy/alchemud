defmodule Alchemud.Players.GenPlayer do
  use ExActor.GenServer

  alias Alchemud.Players.Player
  alias Alchemud.Connections.Connection


  defstart start_link(connection) do
    Connection.send_message(connection, "Greetings, adventurer. To enter the realm, please state your name:")
    initial_state({:waiting_for_name, %Player{}})
  end

  defcall message(connection, player_name), state: {:waiting_for_name, player = %Player{}} do
    case Alchemud.Players.possible_players |> Enum.find(&match?(%Player{name: player_name}, &1)) do
      player = %Player{} -> 

        Connection.send_message(connection, "Please supply your special password:")
        set_and_reply({:waiting_for_password, player}, :ok)
      _ -> 
        IO.puts "No match found."
        Connection.send_message(connection, "Ah! A new adventurer!")
        reply(:ok)
    end
  end

  defcall message(connection, password), state: {:waiting_for_password, player = %Player{}} do
    IO.puts "TO BE IMPLEMENTED!"
    reply(:ok)
  end
end