local enemy = ...

-- A big butterfly boss from Newlink.

local nb_eggs_to_create = 0
local nb_eggs_created = 0
local boss_starting_life = 6
local boss_movement_starting_speed = 20  -- Starting speed in pixels per second, it will gain 5 per life point lost.
local boss_movement_speed = boss_movement_starting_speed

function enemy:on_created()

  self:set_life(boss_starting_life)
  self:set_damage(2)
  self:set_hurt_style("boss")
  self:create_sprite("enemies/bosses/e_fc_eater")
  self:set_size(48, 40)
  self:set_origin(24, 29)
  self:set_invincible()
  self:set_attack_consequence("explosion", 1)
  self:set_attack_consequence("sword", "protected")
  self:set_obstacle_behavior("flying")
end

function enemy:on_restarted()

  sol.timer.start(self, 2000, function() self:egg_phase_soon() end)
  self:go()
end

function enemy:on_hurt(attack)

  local life = self:get_life()
  if life <= 0 then
    -- I am dying: remove the minillosaur eggs.
    local sons_prefix = self:get_name() .. "_baby_eater"
    self:get_map():remove_entities(sons_prefix)
  else
    boss_movement_speed = boss_movement_starting_speed
      + (boss_starting_life - life) * 5
  end
end

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

  local sons_prefix = self:get_name() .. "_baby_eater"
  local nb_sons = self:get_map():get_entities_count(sons_prefix)
  if nb_sons >= 5 then
    -- Delay the egg phase if there are already too much sons.
    sol.timer.start(self, 5000, function() self:egg_phase_soon() end)
  else
    self:stop_movement()
    sol.timer.start(self, 500, function() self:egg_phase() end)
  end
end

function enemy:egg_phase()

  local sprite = self:get_sprite()
  sprite:set_animation("preparing_egg")
  sol.audio.play_sound("gb/enemies/slime_eel_appear") -- boss_charge
  sol.timer.start(self, 1500, function() self:throw_egg() end)

  -- The more the boss is hurt, the more it will throw eggs...
  nb_eggs_to_create = boss_starting_life - self:get_life() + 1
end

function enemy:throw_egg()

  -- Create the egg.
  nb_eggs_created = nb_eggs_created + 1
  local egg_name = self:get_name() .. "_baby_eater_" .. nb_eggs_created
  local egg = self:create_enemy{
    name = egg_name,
    breed = "e_fc_baby_eater_egg_thrown",
    x = 0,
    y = -16,
  }
  egg:set_treasure(nil)
  sol.audio.play_sound("gb/enemies/octorok_firing") -- boss_fireball

  -- See what to do next.
  nb_eggs_to_create = nb_eggs_to_create - 1
  if nb_eggs_to_create > 0 then
    -- Throw another egg in 0.5 second.
    sol.timer.start(self, 500, function() self:throw_egg() end)
  else
    -- Finish the egg phase.
    local sprite = self:get_sprite()
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

