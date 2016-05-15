defmodule Alchemud.Players do
  @moduledoc """
  Code to load players from persistence and store them there again.

  """

  alias Alchemud.Players.Player


  def possible_players do
    [
      %Player{name: "Qqwy", password: Comeonin.Bcrypt.hashpwsalt("topsecret")},
      %Player{name: "Quentia", password: Comeonin.Bcrypt.hashpwsalt("topsecret")}
    ]
  end
end