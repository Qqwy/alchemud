defmodule Alchemud.World.GenEntity do
  use ExActor.GenServer

  #alias Alchemud.World


  defstart start_link(initial_state = %{entity_module: _, uuid: uuid}), gen_server_opts: [name: {:global, {:entity, Map.get(initial_state, :uuid)}}] do
    Process.send_after(self, :tick, Alchemud.World.tick_interval)

    initial_state(initial_state)
  end

  defcall get, state: state, do: reply(state) 


  defhandleinfo :tick, state: state = %{entity_module: entity_module} do
    IO.puts "tick called!"
    new_state = entity_module.handle_tick(state)
    Process.send_after(self, :tick, Alchemud.World.tick_interval)
    new_state(new_state)
  end
end
