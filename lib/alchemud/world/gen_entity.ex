defmodule Alchemud.World.GenEntity do
  use ExActor.GenServer

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

  def add_to_container(state = %Entity{container_uuid: container_uuid, container_pid: old_container_pid}) do
    if old_container_pid, do: Process.unlink(old_container_pid)
    container_pid = Alchemud.World.LocationManager.whereis_location(container_uuid)
    Process.link(container_pid)
    :ok = Alchemud.World.GenLocation.add_entity(container_pid, self, state)
    %Entity{state | container_pid: container_pid}
  end
end
