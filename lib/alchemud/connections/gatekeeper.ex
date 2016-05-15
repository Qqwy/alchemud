  defmodule Alchemud.Connections.Gatekeeper do
    @moduledoc """
    The authentication module that asks for login information
    and also handles player registration.
    """
    alias Alchemud.Players.Player
    alias Alchemud.Connections.Connection

    use Fsm, initial_state: :idle, initial_data: %Player{}
    defstate idle do
      defevent auth(connection, name) do
        existing_player = find_player_by_name(name)
        if existing_player do
          Connection.send_message connection, "#{name}, eh? Please enter your password:"
          next_state(:login_password, existing_player)
        else
          Connection.send_message connection, "Welcome, new adventurer! Please enter a password so I will remember you in the future:"
          next_state(:register_password)
        end
      end
    end

    defstate login_password do
      defevent auth(connection, password), data: player = %Player{password: password} do
        Connection.send_message connection, "Password is right! Welcome!"
        respond(player, :signed_in)
      end

      defevent auth(connection, password), data: %Player{password: _actual_password} do
        Connection.send_message connection, "Ouch! That password is wrong! What was your name again?"
        next_state(:idle)
      end
    end

    defstate register_password do
      defevent auth(connection, password) do
        Connection.send_message connection, "Ok! So I absolutely will not forget, can you confirm the password please:"
        next_state(:register_password_confirm)
      end
    end

    defstate register_password_confirm do
      defevent auth(connection, password_confirm), data: player = %Player{password: password} do
        if password == password_confirm do
          Connection.send_message connection, "You are now signed up! Welcome!"
          respond(player, :signed_in)
        else
          Connection.send_message connection, "Heh, those passwords do not match. Please try again:\r\n\r\nPlease enter a password so I will remember you in the future:"
          next_state(:register_password)
        end
      end
    end

    defstate signed_in do
    end


    defp find_player_by_name(name) do
      Alchemud.Players.possible_players |> Enum.find(&match?(%Player{name: ^name}, &1))
    end
  end