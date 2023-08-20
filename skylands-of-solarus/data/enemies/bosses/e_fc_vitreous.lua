-- Lua script of enemy bosses/vitreous.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite, shadow_sprite
local current_behavior = "toto"
local count = 0

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Create sprites.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  shadow_sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  function shadow_sprite:on_animation_changed(animation)
    local next_animation = "shadow_" .. sprite:get_animation()
    if animation ~= next_animation and shadow_sprite:has_animation(next_animation) then
      shadow_sprite:set_animation(next_animation)
    end
  end
  function enemy:count_children(prefix)
    local remaining = map:get_entities_count(prefix .. "_child")
    return remaining
  end

  enemy:bring_sprite_to_back(shadow_sprite)
  enemy:set_invincible_sprite(shadow_sprite)
  enemy:set_sprite_damage(shadow_sprite, 0)
  -- Other properties.
  enemy:set_life(24)
  enemy:set_damage(1)
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_size(32, 32)
  enemy:set_origin(16, 26)
end

-- Update direction.
function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  if direction4 then
    for _, s in enemy:get_sprites() do
      if direction4 == 1 then
        s:set_direction(math.random(2))
      else
        s:set_direction(direction4)
      end
    end
  end
end


function enemy:set_behavior(behavior)

  -- Prepare sprite animations.
  -- sprite:has_animation("walking")
  -- shadow_sprite:has_animation("shadow_walking")
  -- Start behavior.
  print("b")
  current_behavior = behavior
  if behavior == "stop" then
    sprite:set_xy(0, 0)
    shadow_sprite:set_xy(0, 8)
    sprite:set_animation("stopped")
    shadow_sprite:set_animation("shadow_stopped")
  elseif behavior == "go_to_hero" then
    shadow_sprite:set_animation("shadow_walking")
    sprite:set_animation("walking")
    local m = sol.movement.create("target")
    m:set_target(hero)
    m:set_speed(8)
    m:start(enemy)
  end
  enemy:restart()
  return
end


function enemy:check()
  sol.timer.start(enemy, 720, function()
      enemy:restart()
  end)
  return
end

-- Event called when the enemy should start or restart its movements.
function enemy:on_restarted()

  print(count, current_behavior)
  -- Select behavior.
  local remaining = enemy:count_children("vitreous")
  if remaining == 0 then
    if current_behavior ~= "go_to_hero" then
      enemy:set_behavior("go_to_hero")
    else
      enemy:check()
    end
  else
    if current_behavior ~= "stop" then
  --enemy:stop_movement()
    enemy:set_behavior("stop")
    else
      enemy:check()
    end
  end
  count = count +1
end


