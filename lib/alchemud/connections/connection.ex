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
    conn_state = %ConnectionState{connection_handler: connection_handler, gatekeeper: Gatekeeper.new}

    send_welcome_message(conn_state)
    Gatekeeper.send_greeting(conn_state)
    IO.inspect(conn_state)
    send_prompt(conn_state)
    # TODO: Gatekeeper
    initial_state(conn_state)
  end

  # We have a connected player
  defcast input_received(connection_handler, input), state: conn_state =  %ConnectionState{player: player = %Player{}} do
    input = prettify_input(input)
    # TODO: Move commands into Player
    Alchemud.Players.Player.input_received(%Player{player | connection: conn_state}, input)
    send_prompt(conn_state)
    noreply
  end

  # We are still authenticating. Gatekeeper handles control flow here.
  defcast input_received(connection_handler, input), state: conn_state = %ConnectionState{gatekeeper: gatekeeper} do
    input = prettify_input(input)
    case IO.inspect Gatekeeper.auth(gatekeeper, conn_state, input) do
      {player = %Player{}, gatekeeper = %Gatekeeper{}} -> # Logged in
        send_prompt(conn_state)
        player = Alchemud.Players.Player.logged_in(%Player{player | connection: conn_state})
        new_state(%ConnectionState{conn_state | gatekeeper: gatekeeper, player: player})
      gatekeeper = %Gatekeeper{} -> # Still in gatekeeperland
        send_prompt(conn_state)
        new_state(%ConnectionState{conn_state | gatekeeper: gatekeeper})
    end
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


  def send_message(conn_state, message, opts \\ [])
  def send_message(conn_state = %ConnectionState{connection_handler: connection_handler}, message, [newline: false]) do
    ConnectionProtocol.send_message(connection_handler, message)
  end

  def send_message(conn_state, message, [newline: true]) do
    send_message(conn_state, [message, "\r\n"], newline: false)
  end

  def send_message(conn_state, message, []) do
    send_message(conn_state, message, newline: true)
  end


  @doc """
  Closes the `connection`, prints good bye message.
  """
  def close(conn_state = %ConnectionState{connection_handler: connection_handler}) do
    send_message(conn_state, "\r\nGood bye!\r\n")
    ConnectionProtocol.close(connection_handler)
  end

  defp send_welcome_message(conn_state) do
    send_message(conn_state, @welcome_message)
  end

  defp send_prompt(conn_state) do
    send_message(conn_state, @prompt, newline: false)
  end
end
