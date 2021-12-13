-- Adapted from the script of the enemy named "Minillosaur" in ZSDX

local enemy = ...

-- Jelleggtric egg: a small Jelleggtric that comes from an egg.
-- This enemy is usually be generated by a bigger one.

local sprite = enemy:create_sprite("enemies/e_fc_baby_jelleggtric_egg_thrown")
local in_egg = true



function enemy:on_created()

  -- Enemy
  enemy:set_life(2)
  enemy:set_damage(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_push_hero_on_sword(true)
  enemy:set_obstacle_behavior("flying")

  sprite:set_animation("egg")

  -- Shadow
  local sprite = self:get_sprite()
  shadow_sprite = enemy:create_sprite("enemies/shadows/shadow_8x5")
  function shadow_sprite:on_animation_changed(animation)
    local next_animation = sprite:get_animation()
    if animation ~= next_animation and shadow_sprite:has_animation(next_animation) then
      shadow_sprite:set_animation(next_animation)
    end
  end
  enemy:bring_sprite_to_back(shadow_sprite)
  enemy:set_invincible_sprite(shadow_sprite)
  enemy:set_sprite_damage(shadow_sprite, 0)
  shadow_sprite:set_xy(0, 2)

end




-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  if in_egg then
    sprite:set_animation("egg")
    local angle = self:get_angle(self:get_map():get_entity("hero"))
    local m = sol.movement.create("straight")
    m:set_speed(120)
    m:set_angle(angle)
    m:set_max_distance(80)
    m:set_smooth(false)
    m:start(self)
  else
    self:go_hero()
  end
end

-- An obstacle is reached: in the egg state, break the egg.
function enemy:on_obstacle_reached(movement)

  if sprite:get_animation() == "egg" then
    self:break_egg()
  end
end

-- The movement is finished: in the egg state, break the egg.
function enemy:on_movement_finished(movement)
  -- Same thing as when an obstacle is reached.
  self:on_obstacle_reached(movement)
end

-- The enemy receives an attack whose consequence is "custom".
function enemy:on_custom_attack_received(attack, sprite)

  if attack == "sword" and sprite:get_animation() == "egg" then
    -- The egg is hit by the sword.
    self:break_egg()
    sol.audio.play_sound("enemies/genie_bottle_smash")
  else
    sol.audio.play_sound("enemies/enemy_hit")
  end
end


-- Starts breaking the egg.
function enemy:break_egg()

  self:stop_movement()
  sprite:set_direction(math.random(0, 3))
  sol.audio.play_sound("enemies/genie_bottle_smash") 
  sprite:set_animation("egg_breaking")
end

--  The animation of the sprite is finished.
function sprite:on_animation_finished(animation)

  -- If the egg was breaking, make the Jelleggtric go.
  if animation == "egg_breaking" then
    self:set_animation("walking")
    enemy:set_push_hero_on_sword(false)
    enemy:set_size(8, 16)
    enemy:set_origin(4, 13)
    enemy:go_hero()
  end
end

function enemy:go_hero()

  self:snap_to_grid()
  local m = sol.movement.create("path_finding")
  m:set_speed(40)
  m:start(self)
  self:set_default_attack_consequences()
  in_egg = false
end
