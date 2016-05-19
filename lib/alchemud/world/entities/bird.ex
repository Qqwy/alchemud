defmodule Alchemud.World.Entity.Bird do

  use Alchemud.World.Entity.Behaviour

  def handle_tick(entity) do
    #IO.puts "IM BIRD #{name} AND I CANNOT LIE! I exist in: #{Alchemud.World.Entity.location_info(entity).name}"
    Entity.broadcast(entity.pid, "The #{entity.name} hops around in the bushes.")
    entity
  end

    def after_init(entity, extra_opts) do
      entity
    end
end
