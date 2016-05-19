defmodule Alchemud.Connections.Telnet.Handler do
  @moduledoc """
  A new Connections.Telnet.Handler is started for each person that connects over Telnet.

  Dispatches to the Connection to pass command, and does telnet-specific parsing of commands (ANSI-conversion, etc). 
  """

  @tcp_timeout 360_000

  alias Alchemud.Connections.Connection

  # @behaviour HandlerBehaviour

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [
      ref, 
      %Connection.Telnet{socket: socket, transport: transport}, 
      opts
    ])
    {:ok, pid}
  end

  def init(ref, connection = %Connection.Telnet{}, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    IO.puts "New telnet connection! [socket: #{inspect connection.socket}]"
    
    {:ok, connection_pid} = Connection.start_link(connection)
    loop(%Connection.Telnet{connection | connection_pid: connection_pid})
  end

  def loop(connection = %Connection.Telnet{socket: socket, transport: transport, connection_pid: connection_pid}) do
    case transport.recv(socket, 0, @tcp_timeout) do
      {:ok, <<255, _rest ::binary>>} -> 
        IO.puts "Rejecting Telnet Negotiation options."
        __MODULE__.loop(connection)
      {:ok, data} ->
        IO.puts "Received data from telnet: #{inspect data}"
        Connection.input_received(connection_pid, data)
        __MODULE__.loop(connection)
        #formatted_data = IO.ANSI.format(["The ", :bright, "data", :normal, " is: ", :green, :bright, inspect(data)])
        #send_message(connection, formatted_data)

        #Alchemud.Commands.consume_command(connection, data)

        #send_console_start(connection)
      _ ->
        #Connection.send_message(connection, "\r\n\r\nFor safekeeping, the connection will now be closed.")
        __MODULE__.close(connection)
    end
  end

  # def send_welcome_message(connection = %Connection.Telnet{}) do
  #   send_message(connection, @welcome_message)
  # end

  # def send_console_start(connection = %Connection.Telnet{}) do
  #   send_message(connection, @console_start, newline: false)
  # end


  @doc """
  Sends a message, possibly in IO.chardata-format.
  Pass newline: false to not have the message automatically end with a newline.
  """
  def send_message(%Connection.Telnet{socket: socket, transport: transport}, message) do
    message = IO.ANSI.format(message) |> IO.chardata_to_string
    transport.send(socket, message)
    true
  end

  def close(%Connection.Telnet{socket: socket, transport: transport}) do
    IO.puts "telnet connection quit! [socket: #{inspect socket}]"
    :ok = transport.close(socket)
  end


  defimpl Alchemud.Connections.ConnectionProtocol, for: Connection.Telnet do
    def send_message(connection, message) do
      Alchemud.Connections.Telnet.Handler.send_message(connection, message)
    end

    def close(connection) do
      Alchemud.Connections.Telnet.Handler.close(connection)
    end
  end

end