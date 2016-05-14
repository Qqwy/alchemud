defmodule Alchemud.Connections.HandlerBehaviour do
  # @callback send_message(%Alchemud.Connections.Connection{}, IO.Chardata.t, newline: false) :: true | false

  # @callback close(%Alchemud.Connections.Connection{}) :: true | false
end
