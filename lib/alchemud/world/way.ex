defmodule Way do
  @moduledoc """
  A way between two locations.
  A way is one-way, and linked to the location that is travelled to. It registers itself in the location that is travelled from (adds a monitor to itself there) when the way is made.
  (and is deregistered when the way is exited.)
  """
end