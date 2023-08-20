-- Lua script of enemy rat.

-- A rat who walk randomly in the room

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement


-- Event called when the enemy is initialized.
enemy:register_event("on_created", function(enemy)

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end)

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
enemy:register_event("on_restarted", function(enemy)
  local m = sol.movement.create("straight")
  m:set_speed(0)
  m:start(enemy)
  local direction4 = math.random(4) - 1
  enemy:go(direction4)
end)

-- Event called when the movement is finished
enemy:register_event("on_movement_finished", function(enemy, movement)
  -- stop for a while, looking to a next direction.
  local animation = sprite:get_animation()
  if animation == "walking" then
    sprite:set_animation("stopped")
    sol.timer.start(enemy, 500, function()
      enemy:go(math.random(4)-1)
    end)
  end
end)

-- Event called when an obstacle is reached: turn right
enemy:register_event("on_obstacle_reached", function(enemy, movement)
    -- turn right
    enemy:go((movement:get_direction4() - 1) % 4)
end)

-- Makes the soldier walk towards a direction.
function enemy:go(direction4)

  -- Set the size and origin
  if (direction4 % 2 == 0) then
    enemy:set_size(16, 8)
    enemy:set_origin(8, 5)
  else
    enemy:set_size(8, 16)
    enemy:set_origin(4, 13)
  end
  -- Set the sprite.
  sprite:set_animation("walking")
  sprite:set_direction(direction4)
  -- Set the movement.
  local m = enemy:get_movement()
  local max_distance = 20 + math.random(60)
  m:set_max_distance(max_distance)
  m:set_smooth(true)
  m:set_speed(48)
  m:set_angle(direction4 * math.pi / 2)
end

