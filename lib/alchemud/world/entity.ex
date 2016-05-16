defmodule Alchemud.World.Entity do
  use ExActor.GenServer


  defstruct module: nil, uuid: nil, container_uuid: nil, container_pid: nil, name: "", description: "", state: nil, pid: nil
  alias Alchemud.World.Entity
  


  defstart start(init_state = %Entity{module: _, uuid: uuid}), gen_server_opts: [name: {:global, {:entity, Map.get(init_state, :uuid)}}] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    init_state
    |> add_to_container
    |> initial_state
  end

  defcall get, state: state, do: reply(state) 


  defhandleinfo :tick, state: state = %Entity{module: entity_module} do
    IO.puts "tick called!"
    new_state = entity_module.handle_tick(state)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end

  defcall get_location_info, state: state do
    info = location_info(state)
    reply(info)
  end

  defcall get_location_pid, state: state do
    # TODO: keep containers in mind
    reply(state.container_pid)
  end

  def location_info(state = %Entity{}) do
    state.container_pid |> Alchemud.World.Location.get
  end

  defp add_to_container(state = %Entity{container_uuid: container_uuid, container_pid: old_container_pid}) do
    if old_container_pid, do: Process.unlink(old_container_pid)
    container_pid = Alchemud.World.LocationManager.whereis_location(container_uuid)
    Process.link(container_pid)
    :ok = Alchemud.World.Location.add_entity(container_pid, self, state)
    %Entity{state | container_pid: container_pid}
  end
end
