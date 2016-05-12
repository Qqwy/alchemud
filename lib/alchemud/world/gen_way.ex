defmodule Alchemud.World.GenWay do
  @exit_check_interval 1000

  alias Alchemud.World.Way
  use ExActor.GenServer

  defstart start_link(initial_state = %Way{entrance: entrance_location, exit: exit_location, name: name}), gen_server_opts: [name: {:global, {:way, {entrance_location, exit_location, name}}}] do
    ask_entrance_to_monitor_me(initial_state)
    IO.inspect initial_state
    Process.send(self, :ping_entrance)
    initial_state(initial_state)
  end


  # TODO: Add logic to re-call ping_entrance once entrance location is down (Monitor it!).
  defhandleinfo :ping_entrance, state: state = %Way{} do
    entrance_pid = entrance_pid(state)
    case entrance_pid do
      nil -> Process.send_after(self, :ping_entrance, @exit_check_interval)
      _   -> add_as_exit_to_entrance_location(entrance_pid, state)
    end
    
    noreply
  end

  # TODO: make pattern-match only for the monitored entrance process.
  defhandleinfo {:DOWN, ref, :process, _pid, _reason}, do: Process.send(self, :ping_entrance)



  defp add_as_exit_to_entrance_location(entrance_pid, state = %Way{}) when is_pid(entrance_pid) do
    Process.monitor(entrance_pid)
    entrance_pid.add_exit(self, state)
  end

  defp entrance_pid(state = %Way{entrance: entrance_uuid}), do: Alchemud.World.LocationManager.whereis_location(entrance_location)


end
