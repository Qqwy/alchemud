defprotocol Alchemud.Connections.ConnectionProtocol do
  @vsn 2
  @moduledoc """
  This protocol is intended to be implemented for all connection-types that are supported.
  Each connection-type should create its own struct that contains state on how to find back the external resource (i.e. socket) to respond to.
  Then, each connection-type should add an implementation of this `Connection` protocol for this new struct, so the application is agnostic, and can just call

  `Connection.send_message(some_connection_struct, message)` and it will arrive wherever it is required.
  """
 

  @doc """
  Sends a message to the given connection.
  `message` is in IO.Chardata format.

  """
  require Alchemud.Players.Player
  @type player :: %Alchemud.Players.Player{}

  @spec send_message(any, IO.Chardata.t) :: true | false
  def send_message(connection, message)

  @spec close(any) :: true | false
  def close(connection)

  # @spec register_player(any, player) :: true | false
  # def register_player(connection, player)

  # @spec extract_player_pid(any) :: pid
  # def extract_player_pid(connection)
end

defmodule Alchemud.Connections.Connection.Telnet do
  defstruct socket: nil, transport: nil, connection_pid: nil
end
