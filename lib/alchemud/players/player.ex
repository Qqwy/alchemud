defmodule Alchemud.Players.Player do
  defstruct name: nil, password: nil, logged_in_at: nil, connection: nil

  @doc """
  Sends a message to this player (i.e. the person connected to this player)
  """
  #@spec send_message(%Player{}, IO.Chardata.t, list) :: true | false
  def send_message(player = %__MODULE__{}, message, opts \\ []) do
    IO.inspect player
    IO.inspect message
    IO.inspect opts
    Alchemud.Connections.Connection.send_message(player.connection, message, opts)
  end

  @doc """
  Called by Connection whenever a message by someone linked to this player has been recieved.
  Consumes the message by sending it to all command-listeners.

  """
  def input_received(player, input) do
    Alchemud.Commands.consume_command(player, input)
  end

  def exit(player) do
    Alchemud.Connections.Connection.close(player.connection)
  end
end