defmodule Alchemud.Players.Player do
  @moduledoc """
  A logged-in player. No extra process, `piggybacks` on the Connection process.

  Handles contact with the Character, and dispatches command parsing.

  A player is a non-world-specific identity.
  """

  defstruct name: nil, password: nil, logged_in_at: nil, connection: nil, character: nil
  alias Alchemud.Players.Player
  alias Alchemud.World.Character
  alias Alchemud.Connections.Connection

  @doc """
  Sends a message to this player (i.e. the person connected to this player)
  """
  #@spec send_message(%Player{}, IO.Chardata.t, list) :: true | false
  def send_message(player = %__MODULE__{}, message, opts \\ []) do
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
    Character.shutdown(player)
    Connection.close(player.connection)
  end

  def logged_in(player = %Player{}) do
    {:ok, character} = Character.start(player)
    Process.link(character)
    player = %Player{player | character: character}
    Character.look_at_location(player)
    player
  end
end
