-- Initialize enemy behavior specific to this quest.

-- Include scripts
local enemy_meta = sol.main.get_metatable("enemy")
local enemy_manager = require("scripts/maps/enemy_manager")
local entity_manager= require("scripts/maps/entity_manager") 

-- Get reaction to all weapons.
function enemy_meta:get_hero_weapons_reactions()

  local reactions = {}
  reactions.arrow = self:get_arrow_reaction()
  reactions.boomerang = self:get_attack_consequence("boomerang")
  reactions.explosion = self:get_attack_consequence("explosion")
  reactions.sword = self:get_attack_consequence("sword")
  reactions.thrown_item = self:get_attack_consequence("thrown_item")
  reactions.fire = self:get_fire_reaction()
  reactions.jump_on = self:get_jump_on_reaction()
  reactions.hammer = self:get_hammer_reaction()
  reactions.hookshot = self:get_hookshot_reaction()
  reactions.magic_powder = self:get_magic_powder_reaction()
  reactions.shield = self:get_shield_reaction()
  reactions.thrust = self:get_thrust_reaction()

  return reactions
end

-- Set a reaction to given weapons.
function enemy_meta:set_hero_weapons_reactions(reactions)

  if reactions.arrow then
    self:set_arrow_reaction(reactions.arrow)
  end
  if reactions.boomerang then
    self:set_attack_consequence("boomerang", reactions.boomerang)
  end
  if reactions.explosion then
    self:set_attack_consequence("explosion", reactions.explosion)
  end
  if reactions.sword then
    self:set_attack_consequence("sword", reactions.sword)
  end
  if reactions.thrown_item then
    self:set_attack_consequence("thrown_item", reactions.thrown_item)
  end
  if reactions.fire then
    self:set_fire_reaction(reactions.fire)
  end
  if reactions.jump_on then
    self:set_jump_on_reaction(reactions.jump_on)
  end
  if reactions.hammer then
    self:set_hammer_reaction(reactions.hammer)
  end
  if reactions.hookshot then
    self:set_hookshot_reaction(reactions.hookshot)
  end
  if reactions.magic_powder then
    self:set_magic_powder_reaction(reactions.magic_powder)
  end
  if reactions.shield then
    self:set_shield_reaction(reactions.shield)
  end
  if reactions.thrust then
    self:set_thrust_reaction(reactions.thrust)
  end
end

function enemy_meta:on_created()

  local map = self:get_map()
  local hero = map:get_hero()

  -- Notify the map through a map:on_enemy_created() event on enemy created.
  if map.on_enemy_created then
    map:on_enemy_created(self)
  end

  -- Prevent the hero to be hurt if he is protected by the shield, or let the enemy decide if its on_attacking_hero() event is defined.
  if not self.on_attacking_hero then
    function self:on_attacking_hero(hero, enemy_sprite)
      if not hero:is_shield_protecting(self) and not hero:is_blinking() then
        hero:start_hurt(self, self:get_damage())
      end
    end
  end
end

function enemy_meta:on_hurt(attack)

  if not self.is_hurt_silently then
    if self:get_hurt_style() == "boss" then
      sol.audio.play_sound("enemies/boss_hit")
    else
      sol.audio.play_sound("enemies/enemy_hit")
    end
  end

end

function enemy_meta:on_dying()

  local game = self:get_game()
  if not self.is_hurt_silently then
    if self:get_hurt_style() == "boss" then
      sol.audio.play_sound("enemies/boss_die")
      sol.timer.start(self, 200, function()
          sol.audio.play_sound("items/bomb_explode")
        end)
    else
      sol.audio.play_sound("enemies/enemy_die")
    end
  end
  local death_count = game:get_value("stats_enemy_death_count") or 0
  game:set_value("stats_enemy_death_count", death_count + 1)
  if not game.charm_treasure_is_loading then
    game.acorn_count = game.acorn_count or 0
    game.acorn_count = game.acorn_count + 1
    game.power_fragment_count = game.power_fragment_count or 0
    game.power_fragment_count = game.power_fragment_count + 1
  end
  game.shop_drug_count = game.shop_drug_count or 0
  game.shop_drug_count = game.shop_drug_count + 1
  game.charm_treasure_is_loading = true

end

-- Redefine how to calculate the damage inflicted by the sword.
function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)

  local game = self:get_game()
  local hero = game:get_hero()
  -- Calculate force. Check tunic, sword, spin attack and powerups.
  local base_life_points = self:get_attack_consequence("sword")
  local force_sword = hero:get_game():get_value("force_sword") or 1 
  local force_tunic = game:get_value("force_tunic") or 1
  local force_powerup = hero.get_force_powerup and hero:get_force_powerup() or 1
  local force = base_life_points * force_sword * force_tunic * force_powerup
  if hero:get_state() == "sword spin attack" then
    force = 2 * force -- Double force for spin attack.
  end
  -- Remove life.
  self:remove_life(force)

end

-- Push the given entity, not using a built-in movement to not stop a possible running movement.
local is_pushed = {}
local function push(entity, pushing_entity, speed, duration, entity_sprite, pushing_entity_sprite)

  if is_pushed[entity] then
    return
  end
  is_pushed[entity] = true

  speed = speed or 150
  duration = duration or 100
  entity_sprite = entity_sprite or entity:get_sprite()
  pushing_entity_sprite = pushing_entity_sprite or pushing_entity:get_sprite()

  -- Take the sprite positions as reference for the angle instead of the global positions.
  local trigonometric_functions = {math.cos, math.sin}
  local entity_x, entity_y = entity:get_position()
  local entity_offset_x, entity_offset_y = entity_sprite:get_xy()
  local pushing_entity_x, pushing_entity_y = pushing_entity:get_position()
  local pushing_entity_offset_x, pushing_entity_offset_y = pushing_entity_sprite:get_xy()
  pushing_entity_x = pushing_entity_x + pushing_entity_offset_x
  pushing_entity_y = pushing_entity_y + pushing_entity_offset_y
  entity_x = entity_x + entity_offset_x
  entity_y = entity_y + entity_offset_y

  local angle = math.atan2(pushing_entity_y - entity_y, entity_x - pushing_entity_x)
  local step_axis = {math.max(-1, math.min(1, entity_x - pushing_entity_x)), math.max(-1, math.min(1, entity_y - pushing_entity_y))}

  local function attract_on_axis(axis)

    -- Clean the timer if the entity was removed from outside.
    if not entity:exists() then
      return
    end
    
    local axis_move = {0, 0}
    local axis_move_delay = 10 -- Default timer delay if no move
    entity_x, entity_y = entity:get_position()

    -- Always move pixel by pixel.
    axis_move[axis] = step_axis[axis]
    if axis_move[axis] ~= 0 then

      -- Schedule the next move on this axis depending on the remaining distance and the speed value, avoiding too high and low timers.
      axis_move_delay = 1000.0 / math.max(1, math.min(1000, math.abs(speed * trigonometric_functions[axis](angle))))

      -- Move the entity.
      if not entity:test_obstacles(axis_move[1], axis_move[2]) then
        entity:set_position(entity_x + axis_move[1], entity_y + axis_move[2])
      end
    end

    return axis_move_delay
  end

  -- Start the pixel move schedule.
  local timers = {}
  for i = 1, 2 do
    local initial_delay = attract_on_axis(i)
    if initial_delay then
      timers[i] = sol.timer.start(entity, initial_delay, function()
        return attract_on_axis(i)
      end)
    end
  end

  -- Schedule the end of the push.
  local map = entity:get_map()
  sol.timer.start(map, duration, function() -- Start this timer on the map to take care of timers canceled on entity restart.
    is_pushed[entity] = nil
    for i = 1, 2 do
      if timers[i] then
        timers[i]:stop()
      end
    end
  end)
end

-- Some items needs to push the enemy, the hero or both on a protected reaction.
-- TODO Make something like enemy:set_behavior_on_reaction(weapon, reaction, enemy_behavior, hero_behavior) instead.
local function on_protected(enemy, attack)

  local hero = enemy:get_map():get_hero()

  -- Push the hero if attacked by close range hand weapon.
  if attack == "sword" or attack == "shield" or attack == "thrust" or attack == "hammer" then
    push(hero, enemy, 150, 100)
  end

  -- Push the enemy on all weapon type except fire and magic powder, and if the enemy allow it.
  if attack ~= "fire" and attack ~= "magic_powder" then
    if enemy:is_pushed_back_when_hurt() then -- Workaround : Use the pushed back when hurt behavior to know if the enemy should be pushed by the attack.
      push(enemy, hero, 150, 100)
    end
  end
end

-- Helper function to inflict an explicit reaction from a scripted weapon.
-- TODO this should be in the Solarus API one day
function enemy_meta:receive_attack_consequence(attack, reaction)

  if self:is_enabled() then
    if type(reaction) == "number" then
      self:hurt(reaction)
    elseif reaction == "immobilized" then
      self:immobilize()
    elseif reaction == "protected" then
      on_protected(self, attack)
      sol.audio.play_sound("items/sword_tap")
    elseif reaction == "custom" then
      if self.on_custom_attack_received ~= nil then
        self:on_custom_attack_received(attack)
      end
    elseif type(reaction) == "function" then
      reaction(attack)
    end
  end

end

function enemy_meta:launch_small_boss_dead()

  local game = self:get_game()
  local map = game:get_map()
  local dungeon = game:get_dungeon_index()
  local dungeon_info = game:get_dungeon()
  local savegame = "dungeon_" .. dungeon .. "_small_boss"
  local door_prefix = "door_group_small_boss"
  local music = dungeon_info.music
  sol.audio.play_music(music)
  game:set_value(savegame, true)
  map:open_doors(door_prefix)
  enemy_manager:create_teletransporter_if_small_boss_dead(map, true)
  local x,y,layer = self:get_position()
  map:create_pickable({
      x = x,
      y = y,
      layer = layer, 
      treasure_name = "fairy",
      treasure_variant = 1
    })
  for tile in map:get_entities("tiles_small_boss_") do
    local layer = tile:get_property('end_layer')
    tile:set_layer(layer)
  end

end

function enemy_meta:launch_boss_dead()

  local game = self:get_game()
  local map = game:get_map()
  local dungeon = game:get_dungeon_index()
  local savegame = "dungeon_" .. dungeon .. "_boss"
  local door_prefix = "door_group_boss"
  sol.audio.play_music("23_boss_defeated")
  game:set_value(savegame, true)
  map:open_doors(door_prefix)
  local heart_container = map:get_entity("heart_container")
  heart_container:set_enabled(true)

end

-- Check if the enemy should fall in hole on switching to normal obstacle behavior mode.
enemy_meta:register_event("set_obstacle_behavior", function(enemy)

    if enemy:get_ground_below() == "hole" and enemy:get_obstacle_behavior() == "normal" then
      entity_manager:create_falling_entity(enemy)
    end
  end, false)

-- Check if the enemy should fall in hole on removed.
enemy_meta:register_event("on_removed", function(enemy)

    if enemy:get_ground_below() == "hole" and enemy:get_obstacle_behavior() == "normal" then
      entity_manager:create_falling_entity(enemy)
    end
  end)

-- Create an exclamation symbol near enemy
function enemy_meta:create_symbol_exclamation(sound)

  local map = self:get_map()
  local x, y, layer = self:get_position()
  if sound then
    sol.audio.play_sound("menus/menu_select")
  end
  local symbol = map:create_custom_entity({
      sprite = "entities/symbols/exclamation",
      x = x - 16,
      y = y - 16,
      width = 16,
      height = 16,
      layer = layer + 1,
      direction = 0
    })

  return symbol

end

-- Create an interrogation symbol near enemy
function enemy_meta:create_symbol_interrogation(sound)

  local map = self:get_map()
  local x, y, layer = self:get_position()
  if sound then
    sol.audio.play_sound("menus/menu_select")
  end
  local symbol = map:create_custom_entity({
      sprite = "entities/symbols/interrogation",
      x = x,
      y = y,
      width = 16,
      height = 16,
      layer = layer + 1,
      direction = 0
    })

  return symbol

end

-- Create a collapse symbol near enemy
function enemy_meta:create_symbol_collapse(sound)

  local map = self:get_map()
  local width, height = self:get_sprite():get_size()
  local x, y, layer = self:get_position()
  if sound then
    -- Todo create a custom sound
  end
  local symbol = map:create_custom_entity({
      sprite = "entities/symbols/collapse",
      x = x,
      y = y - height / 2,
      width = 16,
      height = 16,
      layer = layer + 1,
      direction = 0
    })

  return symbol

end

return true
