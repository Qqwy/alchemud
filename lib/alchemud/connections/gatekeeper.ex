  defmodule Alchemud.Connections.Gatekeeper do
    @moduledoc """
    The authentication module that asks for login information
    and also handles player registration.
    """
    alias Alchemud.Players.Player

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