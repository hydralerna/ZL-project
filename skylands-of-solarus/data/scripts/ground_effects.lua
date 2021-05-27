-- Source: "Zelda - A Link To The Dream"
-- Create ground effects: falling on holes, falling leaves, water and lava splash, etc.
-- Use:
-- require("scripts/ground_effects")

-- Variables
local map_meta = sol.main.get_metatable("map")
local enemy_meta = sol.main.get_metatable("enemy")

-- Include scripts
local audio_manager = require("scripts/audio_manager")

-- Create ground effect.
function map_meta:create_ground_effect(effect, x, y, layer, sound_id)

  local map = self
  local sprite_id = "ground_effects/" .. effect
  local effect = map:create_custom_entity({direction=0,
    layer=layer, x=x, y=y, width = 16, height = 16})
  local sprite = effect:create_sprite(sprite_id)
  function sprite:on_animation_finished()
    effect:remove()
  end
  if sound_id then -- Play sound.
    audio_manager:play_sound(sound_id)
  end  
  return ground_effect
end

-- Display effects when an entity falls to the ground.
function map_meta:ground_collision(entity, collision_sound, callback_bad_ground)

  local map = self
  local x, y, layer = entity:get_position()
  local ground = entity:get_ground_below()
  local min_layer = self:get_min_layer()
  local hero = self:get_hero()
  local game = self:get_game()
  -- If ground is empty, fall to lower layer and check ground again.
  while ground == "empty" and layer > min_layer do
     layer = layer - 1
     entity:set_position(x, y, layer)
     ground = entity:get_ground_below()
  end

  -- Destroy enemies falling on a bad ground, if necessary.
  if entity:get_type() == "enemy" then
    local needs_destruction = true
    if map:is_solid_ground(x, y, layer) then needs_destruction = false end
    local obstacle_behavior = entity:get_obstacle_behavior()
    if obstacle_behavior == "flying" then
      needs_destruction = false
      return -- Stop the function. No ground effect in this case.
    end
    if obstacle_behavior == "swimming" and ground == "deep_water" then
      needs_destruction = false
    end
    if needs_destruction then entity:remove() end -- Kill the enemy on bad ground.
  end

  -- If the entity falls on hole, water or lava, remove entity and create effect.
  if ground == "hole" and entity ~= hero then  
    self:create_ground_effect("fall_on_hole", x, y, layer, "falling_on_hole")
    if callback_bad_ground then callback_bad_ground() end
  elseif ground == "deep_water" then
    if entity ~= hero or game:has_ability("swim") then
      self:create_ground_effect("water_splash", x, y, layer, "walk_on_water")
      if callback_bad_ground then callback_bad_ground() end
    end
  elseif ground == "lava" and entity ~= hero then
    self:create_ground_effect("lava_splash", x, y, layer, "walk_on_water")
    if callback_bad_ground then callback_bad_ground() end
  else -- The ground is solid ground. Make ground effect and sound of ground.
    if ground == "shallow_water" then
      self:create_ground_effect("water_splash", x, y, layer, "walk_on_water")
    elseif ground == "grass" then
      self:create_ground_effect("leaves", x, y, layer, "walk_on_grass")
    elseif ground ~= "empty" then -- Normal traversable ground. No ground effect, just a sound.
      local sound = collision_sound or "hero_lands"
      audio_manager:play_sound(sound)
    end
  end
end

-- Functions to check if the position is SOLID ground, i.e., different from hole, lava and deep water.
-- Deep water is NEVER considered solid ground, even if the hero has the "swim" ability.
function map_meta:is_solid_ground(x, y, layer)
  local ground_type = self:get_ground(x, y, layer)
  return self:is_solid_ground_type(ground_type)
end
-- Check if a type of ground is solid ground.
function map_meta:is_solid_ground_type(ground_type)
  if ground_type == "hole" or ground_type == "deep_water" or ground_type == "lava" then
    return false
  end
  return true 
end
