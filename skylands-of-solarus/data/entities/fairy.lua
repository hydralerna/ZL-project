-- Lua script of custom entity fairy.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local danger = false

-- Event called when the custom entity is initialized.
function entity:on_created()
  
  entity:set_can_traverse("hero", true)
  entity:set_traversable_by("hero", true)
  entity:set_traversable_by("enemy", true)
  entity:set_traversable_by("npc", true)
  entity:set_traversable_by("custom_entity", true)
  entity:set_size(4, 4)

end



map:register_event("on_started", function()

  entity:check()

end)



function entity:go(radius, max_radius)

   local x_hero, y_hero, layer_hero = hero:get_position()
   local m = sol.movement.create("circle")
   --local rad = radius == nil and 8 or radius
   m:set_ignore_obstacles()
   if math.random(0, 1) == 1 then
     m:set_clockwise(true)
   else
     m:set_clockwise(false)
   end
   m:set_center(hero)
   m:set_radius_speed(60)
   m:set_radius(radius)
   m:start(entity)
   sol.timer.start(1000, function()
     radius = radius + 1
     m:set_radius(radius)
     return radius < max_radius
   end)

end



function entity:check()

  sol.timer.start(entity, 1000, function()
    local enemy_in_region = false
    for e in map:get_entities_in_region(hero) do
      -- print(e:get_type())
      if e:get_type() == "enemy" then
        if e:get_distance(hero) <= 80 then
          enemy_in_region = true
        end
      end
    end
    local sprite = entity:get_sprite()
    if enemy_in_region and not danger then
      danger = true
      sprite:fade_out(500)
      entity:go(0, 8)
    elseif not enemy_in_region and danger then
      danger = false
      sprite:fade_in(500)
      entity:go(0, 32)
    end
    --local message = danger and "YES" or "NO"
    --print("DANGER: " .. message)
    return true
  end)

end
