defmodule Alchemud.Connections.Connection do
  alias Alchemud.Connections.ConnectionProtocol 
  alias Alchemud.Players.Player

  use ExActor.GenServer


  @welcome_message """



     ▄████████  ▄█        ▄████████    ▄█    █▄       ▄████████   ▄▄▄▄███▄▄▄▄   ███    █▄  ████████▄  
    ███    ███ ███       ███    ███   ███    ███     ███    ███ ▄██▀▀▀███▀▀▀██▄ ███    ███ ███   ▀███ 
    ███    ███ ███       ███    █▀    ███    ███     ███    █▀  ███   ███   ███ ███    ███ ███    ███ 
    ███    ███ ███       ███         ▄███▄▄▄▄███▄▄  ▄███▄▄▄     ███   ███   ███ ███    ███ ███    ███ 
  ▀███████████ ███       ███        ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ███   ███   ███ ███    ███ ███    ███ 
    ███    ███ ███       ███    █▄    ███    ███     ███    █▄  ███   ███   ███ ███    ███ ███    ███ 
    ███    ███ ███▌    ▄ ███    ███   ███    ███     ███    ███ ███   ███   ███ ███    ███ ███   ▄███ 
    ███    █▀  █████▄▄██ ████████▀    ███    █▀      ██████████  ▀█   ███   █▀  ████████▀  ████████▀  
               ▀                                                                                      

                                           O
                                           |
                                    0{XXXX}+====================>
                                           |
                                           O

                                    Welcome!

                                    This is the AlcheMUD, version 0.1
                                    Have a wonderful day!

                                    ~Qqwy/Wiebe-Marten


  ====================================================================================================

  """

  defmodule ConnectionState do
    defstruct gatekeeper: nil, player: nil, connection_handler: nil 
  end
  alias Alchemud.Connections.Connection.ConnectionState
  alias Alchemud.Connections.Gatekeeper

  @prompt IO.ANSI.format([:green, :bright, "~> ", :normal])

  @doc """
  Called by a connection handler when a new connection has been established.

  prints the welcome screen.
  """
  # def new_connection(connection) do
  #   connection
  #   |> send_welcome_message
  #   |> IO.inspect
  #   |> ConnectionProtocol.register_player(%Player{})
  #   |> send_prompt
  # end

  @doc """
  To be called from a Connection Handler process.
  """
  defstart start_link(connection_handler) do
    state = %ConnectionState{connection_handler: connection_handler, gatekeeper: Gatekeeper.new}

    send_welcome_message(state)
    send_message(state, "Hello adventurer, please state your name:")
    IO.inspect(state)
    send_prompt(state)
    # TODO: Gatekeeper
    initial_state(state)
  end

  # We have a connected player
  defcast input_received(connection_handler, input), state: %ConnectionState{connection_handler: connection_handler, player: player = %Player{}} do
    input = prettify_input(input)
    # TODO: Move commands into Player
    Alchemud.Commands.consume_command(connection_handler, input)
    send_prompt(connection_handler)
    noreply
  end

  # We are still authenticating. Gatekeeper handles control flow here.
  defcast input_received(connection_handler, input), state: state = %ConnectionState{gatekeeper: gatekeeper} do
    input = prettify_input(input)
    case Gatekeeper.auth(gatekeeper, state, input) do
      {player = %Player{}, gatekeeper = %Gatekeeper{}} -> # Logged in
        send_prompt(state)
        new_state(%ConnectionState{state | gatekeeper: gatekeeper, player: player})
      gatekeeper = %Gatekeeper{} -> # Still in gatekeeperland
        send_prompt(state)
        new_state(%ConnectionState{state | gatekeeper: gatekeeper})
    end
  end

  defcast input_received(connection_handler, input), state: state = %ConnectionState{gatekeeper: gatekeeper} do
    IO.inspect connection_handler
    IO.inspect input
    IO.inspect state
    IO.inspect gatekeeper
    noreply
  end

  @doc """
  Called by a connection handler when incoming data is received.
  
  `connection` ought to be a struct that implements the ConnectionProtocol.
  `input` ought to be a binary string.
  """
  # def input_received(connection, input) do
  #   input = prettify_input(input)
  #   # TODO: Restructure
  #   player_pid = ConnectionProtocol.extract_player_pid(connection)
  #   Alchemud.Players.GenPlayer.message(player_pid, connection, input)
  #   #Alchemud.Commands.consume_command(connection, input)
  #   send_prompt(connection)
  #   connection
  # end


  @doc """
  Removes any non-printing-characters from the command,  (TODO)
  as well as starting/trailing whitespace.
  
  """
  defp prettify_input(input) do
    input
    |> String.strip
  end

  @doc """
  Sends a message to the given `connection`.
  
  `message` can be in IO.Chardata format.
  
  #### optional parameters:

  - **newline:** Boolean. if true, auto-appends `\r\n` at the end of the message. defaults to true.
  """
  def send_message(connection_state, message, opts)
  def send_message(connection_state = %ConnectionState{connection_handler: connection_handler}, message, newline: false) do
    ConnectionProtocol.send_message(connection_handler, message)
  end

  def send_message(connection_state, message) do
    send_message(connection_state, [message, "\r\n"], newline: false)
  end

  @doc """
  Closes the `connection`, prints good bye message.
  """
  def close(connection_state = %ConnectionState{connection_handler: connection_handler}) do
    send_message(connection_state, "\r\nGood bye!\r\n")
    ConnectionProtocol.close(connection_state)
  end

  defp send_welcome_message(connection_state) do
    send_message(connection_state, @welcome_message)
  end

  defp send_prompt(connection_state) do
    send_message(connection_state, @prompt, newline: false)
  end
end
