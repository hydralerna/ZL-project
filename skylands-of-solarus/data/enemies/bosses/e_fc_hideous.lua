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


function enemy:check()

  sol.timer.start(enemy, 250, function()
    local movement = enemy:get_movement()
    if movement ~= nil then
      local current_direction4 = movement:get_direction4()
      local direction4, _ = crab(enemy:get_direction8_to(hero))
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

  local direction4, angle = crab(enemy:get_direction8_to(hero))
  local m = sol.movement.create("straight")
  m:set_smooth(false)
  m:set_speed(16)
  m:set_angle(angle)
  m:start(enemy)
  shadow_sprite:set_animation("shadow_walking")
  shadow_sprite:set_direction(direction4)
  sprite:set_animation("walking")
  sprite:set_direction(direction4)
end


-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  shadow_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  function shadow_sprite:on_animation_changed(animation)
    local next_animation = "shadow_" .. sprite:get_animation()
    local direction = sprite:get_direction()
    if animation ~= next_animation and shadow_sprite:has_animation(next_animation) then
      shadow_sprite:set_animation(next_animation)
      shadow_sprite:set_direction(direction)
    end
  end
  enemy:bring_sprite_to_back(shadow_sprite)
  enemy:set_invincible_sprite(shadow_sprite)
  enemy:set_sprite_damage(shadow_sprite, 0)
  enemy:set_hurt_style("boss")
  enemy:set_invincible_sprite(sprite)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_life(3)
  enemy:set_damage(1)
  enemy:set_size(32, 16)
  enemy:set_origin(16, 13)


  -- Create the eyes.
  local my_name = self:get_name()
  eye_1 = self:create_enemy{
    name = my_name .. "eye_1",
    breed = "bosses/e_fc_hideous_eye",
    x = -16,
    y = -20,
    layer = 1,
  }
  eye_2 = self:create_enemy{
    name = my_name .. "eye_2",
    breed = "bosses/e_fc_hideous_eye",
    x = 16,
    y = -24,
    layer = 1,
  }
  neck_1_sprite = sol.sprite.create("enemies/bosses/e_fc_hideous")
  neck_1_sprite:set_animation("neck_1")
  neck_2_sprite = sol.sprite.create("enemies/bosses/e_fc_hideous")
  neck_2_sprite:set_animation("neck_2")

  enemy:check()
end


function enemy:on_post_draw()

  local x1, y1 = self:get_position()
  if eye_1:exists() then
    local x2, y2 = eye_1:get_position()
    enemy:display_necks(5, neck_1_sprite, x1 - 6, y1 - 10, x2, y2)
  end
  if eye_2:exists() then
    local x2, y2 = eye_2:get_position()
    enemy:display_necks(6, neck_2_sprite, x1 + 6, y1 - 10, x2, y2)
  end
end

function enemy:display_necks(nb, sprt, x1, y1, x2, y2)

  for i = 1, nb do
    local x = x1 + (x2 - x1) * i / nb
    local y = y1 + (y2 - y1) * i / nb
    enemy:get_map():draw_visual(sprt, x, y)
  end
end


-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()

  enemy:check()
end
