# DEPRECATED
defmodule Alchemud.Players.GenPlayer do
  use ExActor.GenServer

  alias Alchemud.Players.Player
  alias Alchemud.Connections.Connection

  defmodule AuthFSM do
    use Fsm, initial_state: :idle, initial_data: %Player{}
    defstate idle do
      defevent auth(name) do
        existing_player = find_player_by_name(name)
        if existing_player do
          next_state(:login_password, existing_player)
        else
          next_state(:register_password)
        end
      end
    end

    defstate login_password do
      defevent message(password), data: %Player{password: password} do
        IO.puts "Password is right! Welcome!"
        next_state(:signed_in)
      end

      defevent message(password), data: %Player{password: _actual_password} do
        IO.puts "Password is wrong!"
        next_state(:idle)
      end
    end

    defstate register_password do
      defevent message(password) do
        IO.puts "Ok!"
        next_state(:register_password_confirm)
      end
    end

    defstate register_password_confirm do
      defevent message(password_confirm), data: %Player{password: password} do
        IO.puts "WIP"
        if password == password_confirm do
          IO.puts "You are now signed up! Welcome!"
          next_state(:signed_in)
        else
          IO.puts "Passwords do not match. Please try again."
          next_state(:register_password)
        end
      end
    end

    defstate signed_in do
      defevent message(message) do
        # Pass on to Commands.
      end
    end


    defp find_player_by_name(name) do
      Alchemud.Players.possible_players |> Enum.find(&match?(%Player{name: ^name}, &1))
    end
  end


  defstart start_link(connection) do
    Connection.send_message(connection, "Greetings, adventurer. To enter the realm, please state your name:")
    initial_state({:login_name, %Player{connection: connection}})
  end

  defcall message(connection, player_name), state: {:login_name, player = %Player{}} do
    
    case existing_player = find_player_by_name(player_name) do
      %Player{} -> 
        Connection.send_message(connection, "Please supply your special password:")
        existing_player = %Player{existing_player | connection: connection}
        set_and_reply({:login_password, existing_player}, :ok)
      nil -> 
        IO.puts "No match found."
        Connection.send_message(connection, "Ah! A new adventurer! Welcome, #{player_name}")
        reply(:ok)
    end
  end

  defcall message(connection, password), state: {:login_password, player = %Player{name: name, password: password}} do
    IO.puts "Player logged in!"
    Connection.send_message(connection, "Welcome, #{name}! \r\n You have successfully entered the Realm.")

    reply(:ok)
  end

  defcall message(connection, password), state: {:login_password, player = %Player{password: _actual_password}} do
    IO.puts "Player supplied wrong password!"
    Connection.send_message(connection, "That password is incorrect. Please try again")
    set_and_reply({:login_name, player = %Player{connection: connection}}, :ok)

  end

  # DEPRECATED
  defp find_player_by_name(name) do
    Alchemud.Players.possible_players |> Enum.find(&match?(%Player{name: ^name}, &1))
  end


end