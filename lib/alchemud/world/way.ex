defmodule Alchemud.World.Way do
  @moduledoc """
  A Way is a connection between two locations. A way is one-way. (To move back, you need a second way pointing the other way)

  A way has an entrance, and an exit.

  When an entity moves, this happens:
  Location you exit from -> (the entrance of the Way) Way (the exit of the way) -> Location you enter.
  So, the 'entrance' of the way is an exit out of a Location.

  A way is supervised by its 'exit' Location. 
  This means that when a Location crashes, 
  that this location becomes unreachable, 
  as the ways into that Location are now gone as well.

  When a way is made, it pings its 'entrance' every #{@exit_check_interval} milliseconds, to register itself under the `exits` that Location.

  Whenever that monitored `enrance` location goes down, the way will start pinging again until it comes back up.
  """


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

  defhandleinfo :ping_entrance, state: state = %Way{} do
    entrance = entrance_pid(state)
    case entrance do
      nil -> Process.send_after(self, :ping_entrance, @exit_check_interval)
      _   -> add_as_exit_to_entrance_location(entrance, state)
    end
    
    noreply
  end

  defhandleinfo {:DOWN, _ref, :process, _pid, _reason}, state: state do
    if pid == entrance_pid(state) do
      Process.send_after(self, :ping_entrance, @exit_check_interval)
    end
    noreply
  end

  defp add_as_exit_to_entrance_location(entrance, state = %Way{}) when is_pid(entrance) do
    Process.monitor(entrance)
    :ok = Alchemud.World.Location.add_exit(entrance, self, state)
  end

  defp entrance_pid(%Way{entrance: entrance_uuid}) do
    Alchemud.World.LocationManager.whereis_location(entrance_uuid)
  end

end
