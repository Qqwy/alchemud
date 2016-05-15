defmodule Alchemud.World.GenWay do
  @exit_check_interval 1000

  alias Alchemud.World.Way
  use ExActor.GenServer

  defstart start_link(initial_state = %Way{entrance: entrance_location, exit: exit_location, name: name}), gen_server_opts: [name: {:global, {:way, {entrance_location, exit_location, name}}}] do
    IO.inspect initial_state
    send(self, :ping_entrance)
    initial_state(initial_state)
  end

  defcall get, state: state, do: reply(state) 
  defcall get_exit, state: state = %Way{exit: exit_location} , do: reply(exit_location) 

  # TODO: Add logic to re-call ping_entrance once entrance location is down (Monitor it!).
  defhandleinfo :ping_entrance, state: state = %Way{} do
    IO.inspect "[#{inspect self}] Pinging entrance..."
    entrance_pid = entrance_pid(state)
    case entrance_pid do
      nil -> Process.send_after(self, :ping_entrance, @exit_check_interval)
      _   -> add_as_exit_to_entrance_location(entrance_pid, state)
    end
    
    noreply
  end

  # TODO: make pattern-match only for the monitored entrance process.
  defhandleinfo {:DOWN, ref, :process, _pid, _reason} do
    Process.send_after(self, :ping_entrance, @exit_check_interval)
    noreply
  end


  defp add_as_exit_to_entrance_location(entrance_pid, state = %Way{}) when is_pid(entrance_pid) do
    Process.monitor(entrance_pid)
    :ok = Alchemud.World.GenLocation.add_exit(entrance_pid, self, state)
  end

  defp entrance_pid(state = %Way{entrance: entrance_uuid}) do
    IO.inspect "entrance: #{inspect entrance_uuid}"
    Alchemud.World.LocationManager.whereis_location(entrance_uuid)
  end

end
