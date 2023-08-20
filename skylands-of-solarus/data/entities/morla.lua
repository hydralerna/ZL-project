-- Variables
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite = entity:get_sprite()
local hero = map:get_hero()

-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialized.
entity:register_event("on_created", function()

  local map = entity:get_map()
  local sprite = entity:get_sprite()
  --local facing = false
  --local touching = false
  sprite:set_direction(3)
  sprite:set_animation("stopped")
  local _, _, w, h = entity:get_max_bounding_box()
  entity:set_size(w - 4, h - 20)
  entity:set_origin((w - 4) / 2, h - 20)
--print(entity:get_bounding_box())
--print(entity:get_max_bounding_box())
  entity:set_can_traverse("wall", false)
  entity:set_traversable_by("hero", false)
  entity:set_traversable_by("enemy", false)
  entity:set_traversable_by("npc", false)
	entity:add_collision_test("facing", function(_, other)
		if other:get_type() == "hero" then
      --if not facing then
        --facing = true
        --print("facing")
      --end
		end
	end)
	entity:add_collision_test("touching", function(_, other)
		if other:get_type() == "hero" then
      local ex, ey = entity:get_position()
      local hx, hy = hero:get_position()

      --print(ex, ey, hx, hy)
      --if not touching then
        --touching = true
        --print("touching")
      --end
		end
	end)
	entity:add_collision_test("containing", function(_, other)
		if other:get_type() == "hero" then
        entity:bring_to_front()
      --if not facing then
        --containing = true
        --print("containing")
      --end
		end
	end)
  local hx, hy = hero:get_position()
  --print("HERO:", hx, hy)
  --print(entity:test_obstacles([dx, dy, [layer]])
  
  sol.timer.start(720, function()
      local animation = sprite:get_animation()
      local collision = entity:test_obstacles(0, 16)
      local distance = entity:get_distance(hero)
      local angle = entity:get_direction8_to(hero)
      if (distance < 40 and (angle > 3 or angle == 0)) or collision then
        entity:stop_movement()
        if animation ~= "stopped" then
          sprite:set_animation("stopped")
        end
      else
        if animation ~= "walking" then
          entity:walk()
        end
      end
      --print(distance, angle, collision, animation)

    return true
  end)
end)



function entity:walk()

  local m = sol.movement.create("straight")
  m:set_speed(1)
  m:set_angle(3 * math.pi / 2)
  m:start(entity)
  animation = sprite:get_animation()
  if str ~= "walking" then
    sprite:set_animation("walking")
  end
end