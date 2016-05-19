defmodule Alchemud.World.Entity do
  @moduledoc """
  An Entity (can both be a thing or a living being). It is a GenServer that does all the 'plumbing' all entities have. 

  Make specific entities by passing in a module that uses the `Entity.Behaviour`.
  
  Entities are linked to the Location they are in, and thus an malbehaving entity will crash the location and vice versa.
  """

  use ExActor.GenServer


  defstruct module: nil, uuid: nil, container_uuid: nil, container_pid: nil, name: "", description: "", state: nil, pid: nil
  alias Alchemud.World.Entity
  


  defstart start(init_state = %Entity{}, extra_init_data \\ []), gen_server_opts: [name: process_name(init_state)] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    init_state = %Entity{init_state | pid: self}
    init_state
    |> add_to_container
    |> init_state.module.after_init(extra_init_data)
    |> initial_state
  end

  def process_name(%Entity{uuid: uuid}) do
    {:global, {:entity, uuid}}
  end

  defcall get, state: entity, do: reply(entity) 


  defhandleinfo :tick, state: entity = %Entity{} do
    #IO.puts "tick called!"
    new_state = entity.module.handle_tick(entity)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end

  defcall get_location_info, state: entity do
    info = location_info(entity)
    reply(info)
  end

  defcall get_location_pid, state: entity do
    # IN THE FUTURE: keep containers in mind
    reply(entity.container_pid)
  end

  defcall move_to(container_uuid), state: entity do
    entity = add_to_container(%Entity{entity | container_uuid: container_uuid})
    set_and_reply(entity, entity.container_pid)
  end

  defcast receive_broadcast_from_location(broadcaster, message), state: entity do
    Logger.debug "[#{inspect entity}] received broadcast: #{inspect message} from #{inspect broadcaster}"
    entity = entity.module.receive_broadcast_from_location(entity, broadcaster, message)
    new_state(entity)
  end

  def location_info(entity = %Entity{}) do
    entity.container_pid |> Alchemud.World.Location.get
  end

  defcast broadcast(message), state: entity do
    entity.container_pid 
    |> Alchemud.World.Location.broadcast(self, message)
    noreply
  end

  defp add_to_container(entity = %Entity{container_uuid: container_uuid, container_pid: old_container_pid}) do
    if old_container_pid do
      Alchemud.World.Location.remove_entity(old_container_pid, self)
      Process.unlink(old_container_pid)
    end
    container_pid = Alchemud.World.LocationManager.whereis_location(container_uuid)
    Process.link(container_pid)
    :ok = Alchemud.World.Location.add_entity(container_pid, self, entity)
    %Entity{entity | container_pid: container_pid}
  end
end
