defmodule Alchemud.Players.Player do
  defstruct name: nil, password: nil, logged_in_at: nil, connection: nil, character: nil
  alias Alchemud.Players.Player
  alias Alchemud.World.Character
  alias Alchemud.Connections.Connection

  @doc """
  Sends a message to this player (i.e. the person connected to this player)
  """
  #@spec send_message(%Player{}, IO.Chardata.t, list) :: true | false
  def send_message(player = %__MODULE__{}, message, opts \\ []) do
    IO.inspect player
    IO.inspect message
    IO.inspect opts
    Connection.send_message(player.connection, message, opts)
  end

  @doc """
  Called by Connection whenever a message by someone linked to this player has been recieved.
  Consumes the message by sending it to all command-listeners.

  """
  def input_received(player, input) do
    Alchemud.Commands.consume_command(player, input)
  end

  def exit(player) do
    Connection.close(player.connection)
  end

  def logged_in(player = %Player{}) do
    {:ok, character} = Character.start_link(player)
    %Player{player | character: character}
  end

  def look_at_location(player = %Player{}) do
    Character.look_at_location(player)
  end
end
