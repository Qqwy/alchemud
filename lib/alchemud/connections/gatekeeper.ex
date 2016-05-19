  defmodule Alchemud.Connections.Gatekeeper do
    @moduledoc """
    The authentication module that asks for login information
    and also handles player registration.
    """
    alias Alchemud.Players.Player
    alias Alchemud.Connections.Connection

    use Fsm, initial_state: :idle, initial_data: %Player{}

    ###########
    # Exiting
    ###########
    defstate exit_confirm do
      defevent auth(connection, msg), when: msg in ["yes", "exit", "quit"] do
        Connection.close(connection)
        next_state(:exited)
      end

      defevent auth(connection, _) do
        send_message(connection, "I knew it! Please state your name:")
        next_state(:idle)
      end
    end

    defstate exited do
    end

    defevent auth(connection, exit_msg), when: exit_msg in ["exit", "quit"] do
      send_message(connection, "Are you sure you want to quit?")
      next_state(:exit_confirm)
    end


    ############
    # Happy Path
    ############

    defstate idle do
      defevent auth(connection, name), data: player = %Player{} do
        # IN THE FUTURE: Name validation. (no spaces, auto-capitalize, etc) -> extra error path.
        name = sanitize_name(name)
        existing_player = find_player_by_name(name)
        if existing_player do
          send_message(connection, "#{name}, eh? Please enter your password:")
          next_state(:login_password, existing_player)
        else
          send_message(connection, "Ah! Pleased to meet you, #{name}! Please enter a passphrase that I will remember you by in the future:")
          next_state(:register_password, %Player{player | name: name})
        end
      end
    end

    defstate login_password do
      defevent auth(connection, password_attempt), data: player = %Player{password: pass_hash} do
        if Comeonin.Bcrypt.checkpw(password_attempt, pass_hash) do
          send_message(connection, "Password is right! Welcome!")
          respond(player, :signed_in)
        else
          send_message(connection, "Ouch! That passphrase is incorrect! What was your name again?")
          next_state(:idle)
        end
      end
    end

    defstate register_password do
      defevent auth(connection, password), data: player = %Player{} do
        send_message(connection, "Ok! So I absolutely will not forget, can you confirm the passphrase please:")
        pass_hash = Comeonin.Bcrypt.hashpwsalt(password)
        next_state(:register_password_confirm, %Player{player | password: pass_hash})
      end
    end

    defstate register_password_confirm do
      defevent auth(connection, password_confirm), data: player = %Player{password: password} do
        if Comeonin.Bcrypt.checkpw(password_confirm, password) do
          send_message(connection, "You are now signed up! Welcome!")
          respond(player, :signed_in)
        else
          send_message(connection, "Aww, those passphrases do not match. Let's try again...\r\n\r\n")
          send_message(connection, "Please enter a passphrase that I will remember you by in the future:")
          next_state(:register_password)
        end
      end
    end

    defstate signed_in do
    end


    defp send_message(connection, message) do
      Connection.send_message(connection, ["Gatekeeper: ", message])
    end

    def send_greeting(connection) do
      send_message(connection, "Welcome, adventurer! Please, state your name:")
    end


    defp find_player_by_name(name) do
      Alchemud.Players.possible_players |> Enum.find(&match?(%Player{name: ^name}, &1))
    end

    defp sanitize_name(name) do
      name
      |> String.replace(~r{\W}, "")
      |> String.replace("_", "-")
      |> String.capitalize
    end
  end