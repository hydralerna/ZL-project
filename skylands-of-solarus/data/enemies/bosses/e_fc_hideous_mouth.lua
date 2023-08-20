-- Lua script of enemy bosses/e_fc_hideous.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

require("enemies/library/misc")

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite = enemy:get_sprite()
local enemy_body = map:get_entity("hideous")


function enemy:check()

  sol.timer.start(enemy, 250, function()
    local movement = enemy:get_movement()
    local movement_body = enemy_body:get_movement()
    if movement ~= nil then
      local current_direction4 = movement:get_direction4()
      local direction4 = movement_body:get_direction4()
      if direction4 ~= current_direction4 then
        direction4 = current_direction4
        enemy:walk()
      end
    else
      enemy:walk()
    end
    return true
  end)
end


function enemy:walk()

  local movement_body = enemy_body:get_movement()
  if movement_body ~= nil then
    local direction4 = movement_body:get_direction4()
    local angle = (direction4 == 0) and 0 or math.pi
    local m = sol.movement.create("straight")
    m:set_smooth(false)
    m:set_speed(16)
    m:set_angle(angle)
    m:start(enemy)
    sprite:set_animation("walking")
    sprite:set_direction(direction4)
    local x = (direction4 == 0) and 8 or -8
    sprite:set_xy(x, 0)
  end
end


-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_hurt_style("boss")
  enemy:set_invincible_sprite(sprite)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_life(3)
  enemy:set_damage(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:check()
end



-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()

  enemy:check()
end
