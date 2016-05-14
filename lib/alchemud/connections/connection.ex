defmodule Alchemud.Connections.Connection do
  alias Alchemud.Connections.ConnectionProtocol 


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

  @console_start "~> "

  @doc """
  Called by a connection handler when a new connection has been established.

  prints the welcome screen.
  """
  def new_connection(connection) do
    send_welcome_message(connection)
    send_console_start(connection)
  end

  @doc """
  Called by a connection handler when incoming data is received.
  
  `connection` ought to be a struct that implements the ConnectionProtocol.
  `input` ought to be a binary string.
  """
  def input_received(connection, input) do
    Alchemud.Commands.consume_command(connection, input)
    send_console_start(connection)
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
    true
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

  defp send_console_start(connection) do
    send_message(connection, @console_start, newline: false)
  end




end
