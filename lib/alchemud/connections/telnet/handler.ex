defmodule Alchemud.Connections.Telnet.Handler do
  @tcp_timeout 360_000

  @welcome_message """


  =================================
  
         O
         |
  0{XXXX}+====================>
         |
         O

  Welcome!

  This is the AlcheMUD, version 0.1
  Have a wonderful day!

  ~Qqwy/Wiebe-Marten


  =================================

  """

  @console_start "~> "

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    IO.puts "New telnet connection! [socket: #{inspect socket}]"
    send_welcome_message(socket, transport)
    send_console_start(socket, transport)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    case transport.recv(socket, 0, @tcp_timeout) do
      {:ok, data} ->
        IO.puts "Received data from telnet: #{inspect data}"
        transport.send(socket, "The data is: #{data}")
        send_console_start(socket, transport)
        loop(socket, transport)
      _ ->
        IO.puts "telnet connection quit! [socket: #{inspect socket}]"
        :ok = transport.close(socket)
    end
  end

  def send_welcome_message(socket, transport) do
    message = 
    transport.send(socket, @welcome_message)
  end

  def send_console_start(socket, transport) do
    transport.send(socket, @console_start)
  end
end