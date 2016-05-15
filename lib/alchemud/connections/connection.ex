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

  defmodule State do
    defstruct gatekeeper: nil, player: nil, connection_handler: nil 
  end
  alias Alchemud.Connections.Connection.State as Connection.State
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
    init_state = %Connection.State{connection_handler: connection_handler, gatekeeper: Gatekeeper.new}

    connection
    |> send_welcome_message
    |> IO.inspect
    |> send_prompt
    # TODO: Gatekeeper
    initial_state(init_state)
  end

  # We have a connected player
  defcast input_received(connection_handler, input), state: %Connection.State{connection_handler: connection_handler, player: player = %Player{}} do
    input = prettify_input(input)
    # TODO: Move commands into Player
    Alchemud.Commands.consume_command(connection, input)
    send_prompt(connection_handler)
  end

  # We are still authenticating. Gatekeeper handles control flow here.
  defcast input_received(connection_handler, input), state: state = %Connection.State{connection_handler: connection_handler, gatekeeper: gatekeeper} do
    input = prettify_input(input)
    case Gatekeeper.auth(gatekeeper, input) do
      {player = %Player{}, gatekeeper = %Gatekeeper{}} -> # Logged in
        send_prompt(connection_handler)
        new_state(%Connection.State{state | gatekeeper: gatekeeper, player: player})
      gatekeeper = %Gatekeeper{} -> # Still in gatekeeperland
        new_state(%Connection.State{state | gatekeeper: gatekeeper})
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
  def send_message(connection, message, opts)
  def send_message(connection, message, newline: false) do
    ConnectionProtocol.send_message(connection, message)
    connection
  end

  def send_message(connection, message) do
    send_message(connection, [message, "\r\n"], newline: false)
  end

  @doc """
  Closes the `connection`, prints good bye message.
  """
  def close(connection) do
    send_message(connection, "\r\nGood bye!\r\n")
    ConnectionProtocol.close(connection)
  end

  defp send_welcome_message(connection) do
    send_message(connection, @welcome_message)
  end

  defp send_prompt(connection) do
    send_message(connection, @prompt, newline: false)
  end
end