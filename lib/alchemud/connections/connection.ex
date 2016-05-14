defmodule Alchemud.Connections.Connection do

  @doc """
  Using a combination of the module that implements the Connection handler behaviour,
  and a data type of whatever information this module needs to find back the resource it got,
  we can pass this connection around.
  """
  defstruct handler_module: nil, connection_info: nil
end