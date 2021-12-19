-- Adapted from the script of the enemy named "Papillosaur King" in ZSDX

local enemy = ...


require("scripts/hud/lvl_and_exp")

local game = enemy:get_game()
local nb_eggs_to_create = 0
local nb_eggs_created = 0
local boss_starting_life = 12
local boss_movement_starting_speed = 20  -- Starting speed in pixels per second, it will gain 5 per life point lost.
local boss_movement_speed = boss_movement_starting_speed
local protected = false


function enemy:on_created()

  -- Boss named "Jelleggtric"
  self:set_life(boss_starting_life)
  self:set_damage(2)
  self:set_hurt_style("boss")
  self:create_sprite("enemies/bosses/e_fc_jelleggtric", "boss")
  self:set_size(48, 40)
  self:set_origin(24, 37)
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("explosion", 1)
  self:set_obstacle_behavior("flying")
  -- Shadow
  local sprite = self:get_sprite("boss")
  shadow_sprite = enemy:create_sprite("enemies/shadows/shadow_16x12", "shadow")
  function shadow_sprite:on_animation_changed(animation)
    local next_animation = sprite:get_animation()
    if animation ~= next_animation and shadow_sprite:has_animation(next_animation) then
      shadow_sprite:set_animation(next_animation)
    end
  end
  enemy:bring_sprite_to_back(shadow_sprite)
  enemy:set_invincible_sprite(shadow_sprite)
  enemy:set_sprite_damage(shadow_sprite, 0)
  --shadow_sprite:set_xy(0, 0)
  self:go()
end


function enemy:on_restarted()

  sol.timer.start(self, 2000, function() self:egg_phase_soon() end)
  if protected then
    self:run_away()
  else
    self:go()
  end
end


function enemy:on_hurt(attack)

  sol.audio.play_sound("enemies/boss_hit")
  local life = self:get_life()
  if life <= 0 then
    -- I am dying: remove the Jellegtric eggs.
    local sons_prefix = self:get_name() .. "_baby_jelleggtric_"
    self:get_map():remove_entities(sons_prefix)
  else
    boss_movement_speed = boss_movement_starting_speed
      + (boss_starting_life - life) * 5
  end
  protected = true
end


--function enemy:on_hurt_by_sword(hero, enemy_sprite)

--  local sprite = self:get_sprite("boss")
--end


function enemy:go()

  local m
  if self:get_life() > 1 then
    m = sol.movement.create("random_path")
  else
    -- The enemy is now desperate and angry against our hero.
    m = sol.movement.create("target")
  end
  m:set_speed(boss_movement_speed)
  m:start(self)
end


function enemy:egg_phase_soon()

  
  local function set_egg_phase(duration)
      self:stop_movement()
      sol.timer.start(self, duration, function() self:egg_phase() end)
  end
  local sons_prefix = self:get_name() .. "_baby_jelleggtric_"
  local nb_sons = self:get_map():get_entities_count(sons_prefix)
  if nb_sons >= 5 then
    local animation = self:get_sprite("boss"):get_animation()
    if protected then
        set_egg_phase(7000)
        --print("set_egg_phase")
    else
      -- Delay the egg phase if there are already too much sons.
      sol.timer.start(self, 5000, function() self:egg_phase_soon() end)
    end
  else
    set_egg_phase(500)
  end
end


function enemy:egg_phase()

  protected = false
  self:set_attack_consequence("sword", 1)
  local sprite = self:get_sprite("boss")
  sprite:set_animation("preparing_egg")
  sol.audio.play_sound("enemies/genie_appear") -- boss_charge
  sol.timer.start(self, 1500, function() self:throw_egg() end)

  -- The more the boss is hurt, the more it will throw eggs...
  nb_eggs_to_create = boss_starting_life - self:get_life() + 1
end


function enemy:throw_egg()

  -- Create the egg.
  nb_eggs_created = nb_eggs_created + 1
  local egg_name = self:get_name() .. "_baby_jelleggtric_" .. nb_eggs_created
  local egg = self:create_enemy{
    name = egg_name,
    breed = "e_fc_baby_jelleggtric_egg_thrown",
    x = 0,
    y = -16,
  }
  egg:set_treasure(nil)
  sol.audio.play_sound("enemies/octorok_firing") -- boss_fireball

  -- See what to do next.
  nb_eggs_to_create = nb_eggs_to_create - 1
  if nb_eggs_to_create > 0 then
    -- Throw another egg in 0.5 second.
    sol.timer.start(self, 500, function() self:throw_egg() end)
  else
    -- Finish the egg phase.
    local sprite = self:get_sprite("boss")
    sprite:set_animation("walking")
    -- Don't throw eggs when desperate!
    if self:get_life() > 1 then
      -- Schedule the next one in a few seconds.
      local duration = 3500 + (math.random(3) * 1000)
      sol.timer.start(self, duration, function() self:egg_phase_soon() end)
    end
    self:go()
  end
end


function enemy:run_away()

  local sprite = self:get_sprite("boss")
  self:set_attack_consequence("sword", "protected")
  sprite:set_animation("walking2")
  sol.audio.play_sound("misc/sword_electricity")
  sol.timer.start(self, 720, function()
      if protected then
        sol.audio.play_sound("misc/sword_electricity")
        return true
      end
  end)
  self:stop_movement()
  local m
  local hero = self:get_map():get_hero()
  local angle = (2 * math.pi) - self:get_angle(hero)
  if self:get_life() > 1 then
    m = sol.movement.create("straight")
    m:set_angle(angle)
    --print(angle)
    m:set_speed(boss_movement_speed)
    m:start(self)
  end
  local duration = 3500 + (math.random(3) * 1000)
  sol.timer.start(self, duration, function() self:egg_phase_soon() end)
end


function enemy:on_dying()

  game:add_exp(30)
end