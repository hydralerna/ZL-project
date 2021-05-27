-- Lua script of enemy spiderskull by diarandor.
-- Some modifications by froggy77.
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
local detection_distance = 80
local acidball_distance = 160
local min_walking_speed, max_walking_speed = 20, 30
local min_running_speed, max_running_speed = 40, 50
local jumping_speed = 60
local can_dodge_sword = true
local defenseless_delay = 500 -- Duration after jump when enemy cannot hurt sword.
local jump_duration, max_height = 1000, 40
local acidball_speed = 120
local damage_acidball = 12

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
  enemy:bring_sprite_to_back(shadow_sprite)
  enemy:set_invincible_sprite(shadow_sprite)
  enemy:set_sprite_damage(shadow_sprite, 0)
  -- Other properties.
  enemy:set_size(32, 24)
  enemy:set_origin(16, 17)
  enemy:set_life(4)
  enemy:set_damage(4)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)
  enemy:set_obstacle_behavior("flying")
  --TODOenemy:set_default_behavior_on_hero_shield("enemy_strong_to_shield_push")
end

-- Update direction.
function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  if direction4 then
    for _, s in enemy:get_sprites() do
      s:set_direction(direction4)
    end
  end
end

-- Remove life when hurt by sword.
function enemy:start_hurt_by_sword()
  local damage = game:get_ability("sword")
  local spin_attack = hero:get_sprite():get_animation() == "spin_attack"
  if spin_attack then damage = 2 * damage end
  enemy:hurt(damage)
end

-- Used to restart sword reaction: dodge sword attacks if possible.
function enemy:initialize_sword_reaction()
  enemy:set_attack_consequence_sprite(sprite, "sword", function()
    if can_dodge_sword then
      enemy:jump_to_hero()
    else -- Hurt the enemy.
      enemy:start_hurt_by_sword()
    end
  end)
end

-- Event called when the enemy should start or restart its movements.
function enemy:on_restarted()
  enemy:stop_movement()
  can_dodge_sword = true
  enemy:initialize_sword_reaction() -- Restart reaction to sword attacks.
  enemy:set_can_attack(true)
  -- Update animations.
  sprite:set_xy(0, 0)
  sprite:set_animation("stopped")
  shadow_sprite:set_animation("shadow_stopped")
  -- Select behavior.
  local delay = math.random(500, 1000)
  sol.timer.start(enemy, delay, function()
    if enemy:get_distance(hero) <= detection_distance then
      enemy:start_walking("go_to_hero")
    elseif enemy:get_distance(hero) <= acidball_distance
        and enemy:get_direction4_to(hero) == sprite:get_direction()
        and math.random(1, 2) == 1 -- Probability for acidball attack: 50%
        then
      enemy:throw_acidball()
    else
      enemy:start_walking("wander")
    end
  end)
end


function enemy:start_walking(behavior)
  -- Prepare sprite animations.
  sprite:has_animation("walking")
  shadow_sprite:has_animation("shadow_walking")
  -- Start behavior.
  if behavior == "go_to_hero" then
    sprite:set_animation("walking")
    shadow_sprite:set_animation("shadow_walking")
    local m = sol.movement.create("target")
    m:set_target(hero)
    m:set_speed(math.random(min_running_speed, max_running_speed))
    m:start(enemy)
    sol.timer.start(enemy, 250, function()
      if enemy:get_distance(hero) > detection_distance then
        enemy:restart()
        return
      end
      return true
    end)
  elseif behavior == "wander" then
    sprite:set_animation("walking")
    shadow_sprite:set_animation("shadow_walking")
    local m = sol.movement.create("straight")
    m:set_smooth(false)
    m:set_angle(math.random(0, 3) * math.pi / 2)
    m:set_speed(math.random(min_walking_speed, max_walking_speed))
    m:set_max_distance(math.random(16, 80))
    function m:on_obstacle_reached() enemy:restart() end
    function m:on_finished() enemy:restart() end
    m:start(enemy)
  end
end

-- Jump towards hero.
function enemy:jump_to_hero()
  sol.timer.stop_all(enemy) -- Stop behavior timers.
  -- Set jumping state, animation and sound.
  sprite:set_animation("jumping")
  shadow_sprite:set_animation("shadow_jumping")
  sol.audio.play_sound("jump")
  enemy:set_invincible_sprite(sprite) -- Set invincible.
  enemy:set_can_attack(false) -- Do not attack hero during jump.
  -- Start shift on sprite.
  local function f(t) -- Shifting function.
    return math.floor(4 * max_height * (t / jump_duration - (t / jump_duration) ^ 2))
  end
  local t = 0
  local refreshing_time = 10
  sol.timer.start(enemy, refreshing_time, function() -- Update shift each 10 milliseconds.
    sprite:set_xy(0, -f(t))
    t = t + refreshing_time
    if t > jump_duration then return false
      else return true
    end
  end) 
  -- Add movement towards near the hero during the jump. The jump does not target the hero.
  -- The angle is partially random to avoid too many enemies overlapping.
  local m = sol.movement.create("straight")
  local angle = self:get_angle(self:get_map():get_hero())
  local d = 2*math.random() - 1 -- Random real number in [-1,1].
  angle = angle + d*math.pi/4 -- Alter jumping angle, randomly.
  m:set_speed(jumping_speed)
  m:set_angle(angle)
  m:start(enemy)
  -- Finish the jump.
  sol.timer.start(enemy, jump_duration, function()
    sol.audio.play_sound("hero_lands")
    can_dodge_sword = false -- Allow to receive damage temporarily.
    enemy:set_default_attack_consequences_sprite(sprite) -- Stop invincibility after jump.
    enemy:set_can_attack(true)
    enemy:stop_movement()
    sprite:set_xy(0, 0)
    sprite:set_animation("stopped")
    shadow_sprite:set_animation("shadow_stopped")
    sol.timer.start(enemy, defenseless_delay, function()
      enemy:restart()
    end)
  end)
end

-- Throws an acid ball.
function enemy:throw_acidball()
  -- Prepare enemy animation.
  sprite:set_animation("throw_acidball", function()
    enemy:restart()
  end)
  sol.timer.start(enemy, 800, function()
    sol.audio.play_sound("walk_on_water")
    -- Create acidball projectile.
    local x, y, layer = enemy:get_position()
    local dir = sprite:get_direction()
    local angle = dir * math.pi / 2
    local x, y = x + 16 * math.cos(angle), y - 16 * math.sin(angle)
    local acidball = map:create_enemy({x = x, y = y, layer = layer, direction = dir,
      breed = "projectiles/generic_projectile"})
    local acidball_sprite = acidball:create_sprite(enemy:get_sprite():get_animation_set())
    acidball_sprite:set_animation("acidball_walking")
    acidball:set_damage(damage_acidball)
    sol.timer.start(acidball, 500, function() -- Delay for not hurting the throwing enemy.
      acidball:allow_hurt_enemies(true)
    end)
    -- Destroy acidball.
    function acidball:explode()
        acidball:stop_movement()
        sol.audio.play_sound("enemy_killed")
        acidball:get_sprite():set_animation("acidball_explosion", function()
          acidball:remove()
        end)
        acidball.explode = function() end -- Clear function, to call it only once.
    end
    -- Start movement.
    local m = sol.movement.create("straight")
    m:set_smooth(false)
    m:set_angle(angle)
    m:set_speed(acidball_speed)
    m:set_max_distance(100)
    function m:on_obstacle_reached() acidball:explode() end
    function m:on_finished() acidball:explode() end
    m:start(acidball)
    -- Set acidball custom properties.
    acidball:set_invincible()
    -- acidball:set_default_behavior_on_hero_shield("normal_shield_push")
    function acidball:on_shield_collision(shield)
        acidball:explode() -- Kill enemy.
    end
  end)
end
