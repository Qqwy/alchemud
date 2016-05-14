defmodule Alchemud.Connections.Telnet.Handler do
  @tcp_timeout 360_000

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

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, {socket, transport}, opts])
    {:ok, pid}
  end

  def init(ref, {socket, transport}, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    IO.puts "New telnet connection! [socket: #{inspect socket}]"
    send_welcome_message({socket, transport})
    send_console_start({socket, transport})
    loop({socket, transport})
  end

  def loop({socket, transport}) do
    case transport.recv(socket, 0, @tcp_timeout) do
      {:ok, msg} when msg in ["exit\r\n", "quit\r\n"]
        -> 
        __MODULE__.close_connection({socket, transport})
      {:ok, data} ->
        IO.puts "Received data from telnet: #{inspect data}"
        formatted_data = IO.ANSI.format(["The ", :bright, "data", :normal, " is: ", :green, :bright, inspect(data)])
        send_message({socket, transport}, formatted_data)

        Alchemud.Commands.consume_command({socket, transport}, data)

        send_console_start({socket, transport})
        __MODULE__.loop({socket, transport}) # Ensure that code is reloaded, if module was recompiled.
      _ ->
        send_message({socket, transport}, "\r\n\r\nFor safekeeping, the connection will now be closed.")
        __MODULE__.close_connection({socket, transport})
    end
  end

  def send_welcome_message({socket, transport}) do
    send_message({socket, transport}, @welcome_message)
  end

  def send_console_start({socket, transport}) do
    send_message({socket, transport}, @console_start, newline: false)
  end


  @doc """
  Sends a message, possibly in IO.chardata-format.
  Pass newline: false to not have the message automatically end with a newline.
  """
  def send_message({socket, transport}, message, newline: false) do
    transport.send(socket, message |> IO.chardata_to_string)
    true
  end

  def send_message({socket, transport}, message) do
    send_message({socket, transport}, [message, "\r\n"], newline: false)
  end


  def close_connection({socket, transport}) do
    send_message({socket, transport}, "\r\nGood bye!\r\n")
    IO.puts "telnet connection quit! [socket: #{inspect socket}]"
    :ok = transport.close(socket)
  end
end