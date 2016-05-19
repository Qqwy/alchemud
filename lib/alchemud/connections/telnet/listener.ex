defmodule Alchemud.Connections.Telnet.Listener do
  @moduledoc """
  Wrapper for Ranch with the settings we want, to accept Telnet connections.
  
  Ranch starts listening on Telnet port #{@telnet_port}
  """

  @telnet_port 8034

  # use ExActor.GenServer

  # defstart start_link(port \\ 8034) do
  #   opts = [port: port]
  #   {:ok, _} = :ranch.start_listener(:foobar, 100, :ranch_tcp, opts, __MODULE__, [])
  #   initial_state(nil)
  # end

  def start_link(port \\ @telnet_port) do
    opts = [port: port]
    IO.puts "Starting telnet on port 8034..."
    {:ok, _} = :ranch.start_listener(:foobar, 100, :ranch_tcp, opts, Alchemud.Connections.Telnet.Handler, [])
  end
end