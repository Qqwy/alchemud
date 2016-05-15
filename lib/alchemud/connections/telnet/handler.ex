defmodule Alchemud.Connections.Telnet.Handler do
  @tcp_timeout 360_000

  alias Alchemud.Connections.{Connection, HandlerBehaviour}

  # @behaviour HandlerBehaviour

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [
      ref, 
      %Connection.Telnet{socket: socket, transport: transport}, 
      opts
    ])
    {:ok, pid}
  end

  def init(ref, connection = %Connection.Telnet{socket: socket, transport: transport}, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    IO.puts "New telnet connection! [socket: #{inspect socket}]"
    
    connection
    |> Connection.new_connection
    |> loop
  end

  def loop(connection = %Connection.Telnet{socket: socket, transport: transport}) do
    case transport.recv(socket, 0, @tcp_timeout) do
      {:ok, <<255, _rest ::binary>>} -> 
        IO.puts "Rejecting Telnet Negotiation options."
        __MODULE__.loop(connection)
      {:ok, data} ->
        IO.puts "Received data from telnet: #{inspect data}"
        connection
        |> Connection.input_received(data)
        |> __MODULE__.loop
        #formatted_data = IO.ANSI.format(["The ", :bright, "data", :normal, " is: ", :green, :bright, inspect(data)])
        #send_message(connection, formatted_data)

        #Alchemud.Commands.consume_command(connection, data)

        #send_console_start(connection)
      _ ->
        Connection.send_message(connection, "\r\n\r\nFor safekeeping, the connection will now be closed.")
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
    transport.send(socket, message |> IO.chardata_to_string)
    true
  end

  def close(connection = %Connection.Telnet{socket: socket, transport: transport}) do
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

    def register_player(connection, player) do
      IO.puts "FOOBAR"
      {:ok, player_pid} = Alchemud.Players.GenPlayer.start_link(connection)
      %Connection.Telnet{connection | player_pid: player_pid}
    end

    def extract_player_pid(%Connection.Telnet{player_pid: pid}), do: pid
  end

end