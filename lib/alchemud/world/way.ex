defmodule Alchemud.World.Way do
  @exit_check_interval 1000

  defstruct entrance: nil, exit: nil, name: nil, pid: nil
  alias Alchemud.World.Way

  
  use ExActor.GenServer

  defstart start_link(init_state = %Way{}), gen_server_opts: [name: process_name(init_state)] do
    send(self, :ping_entrance)
    initial_state(init_state)
  end

  def process_name(%Way{entrance: entrance_location, exit: exit_location, name: name}) do
    {:global, {:way, {entrance_location, exit_location, name}}}
  end

  defcall get, state: state, do: reply(state) 
  defcall get_exit, state: state = %Way{} , do: reply(state.exit_location) 

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
  defhandleinfo {:DOWN, _ref, :process, _pid, _reason} do
    Process.send_after(self, :ping_entrance, @exit_check_interval)
    noreply
  end

  defp add_as_exit_to_entrance_location(entrance_pid, state = %Way{}) when is_pid(entrance_pid) do
    Process.monitor(entrance_pid)
    :ok = Alchemud.World.Location.add_exit(entrance_pid, self, state)
  end

  defp entrance_pid(%Way{entrance: entrance_uuid}) do
    Alchemud.World.LocationManager.whereis_location(entrance_uuid)
  end

end
