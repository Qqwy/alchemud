defmodule Alchemud.World.GenWay do
  alias Alchemud.World.Way
  use ExActor.GenServer

  defstart start_link(initial_state = %Way{entrance: entrance_location, exit: exit_location, name: name}), gen_server_opts: [name: {:global, {:way, {entrance_location, exit_location, name}}}] do
    ask_entrance_to_monitor_me(initial_state)
    IO.inspect initial_state
    initial_state(initial_state)
  end

  defp ask_entrance_to_monitor_me(state = %Way{entrance: entrance_location, exit: exit_location}) do
    entrance_location_pid = Alchemud.World.LocationManager.whereis_location(entrance_location)
    entrance_location_pid.add_exit(self, state)
  end
end