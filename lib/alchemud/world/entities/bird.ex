defmodule Alchemud.World.Entity.Bird do
  @moduledoc """
  A simple test entity.
  """

  use Alchemud.World.Entity.Behaviour
  use Timex

  def handle_tick(entity) do
    #IO.puts "IM BIRD #{name} AND I CANNOT LIE! I exist in: #{Alchemud.World.Entity.location_info(entity).name}"
    #IO.inspect(["diff:", entity.state.timestamp_of_last_action, DateTime.now ])
    if Timex.diff(entity.state.timestamp_of_last_action, DateTime.now, :seconds) > entity.state.next_action_timeout do
      Entity.broadcast(entity.pid, "The #{entity.name} hops around in the bushes.")
      %Entity{entity | state: set_next_action_timeout(entity.state)}
    else
      entity
    end
  end

    def after_init(entity, extra_opts) do
      entity = %Entity{entity | state: set_next_action_timeout(%{timestamp_of_last_action: nil, next_action_timeout: nil})}
      entity
    end

    def set_next_action_timeout(state) do
      timeout = 3..20 |> Enum.random
      %{state | timestamp_of_last_action: DateTime.now, next_action_timeout: timeout}
    end
end
