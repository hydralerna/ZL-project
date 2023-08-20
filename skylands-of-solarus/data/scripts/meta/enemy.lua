-- Initialize enemy behavior specific to this quest.
local enemy_meta = sol.main.get_metatable("enemy")


-- Attach a custom damage to the sprites of the enemy.
function enemy_meta:get_sprite_damage(sprite)
  return (sprite and sprite.custom_damage) or self:get_damage()
end
function enemy_meta:set_sprite_damage(sprite, damage)
  sprite.custom_damage = damage
end

-- Warning: do not override these functions if you use the "custom shield" script.
function enemy_meta:on_attacking_hero(hero, enemy_sprite)
  local enemy = self
  -- Do nothing if enemy sprite cannot hurt hero.
  if enemy:get_sprite_damage(enemy_sprite) == 0 then return end
  local collision_mode = enemy:get_attacking_collision_mode()
  if not hero:overlaps(enemy, collision_mode) then return end  
  -- Do nothing when shield is protecting.
  if hero.is_shield_protecting_from_enemy
      and hero:is_shield_protecting_from_enemy(enemy, enemy_sprite) then
    return
  end
  -- Check for a custom attacking collision test.
  if enemy.custom_attacking_collision_test and
      not enemy:custom_attacking_collision_test(enemy_sprite) then
    return
  end
  -- Otherwise, hero is not protected. Use built-in behavior.
  local damage = enemy:get_damage()
  if enemy_sprite then
    hero:start_hurt(enemy, enemy_sprite, damage)
  else
    hero:start_hurt(enemy, damage)
  end
end

-- Function when the enemy is hurt.
function enemy_meta:on_hurt()

  local enemy = self
  if enemy:get_life() == 0 then
    enemy:get_sprite():set_animation("dying")
  end
end

-- Function to get enemy ID.
-- e.g.
-- enemy:get_id()    is equivalent to  enemy:get_property("id").
function enemy_meta:get_id()
  
  return self:get_property("id")
end

-- Function to set an ID. 
-- e.g.
-- enemy:set_id()         will generate an automatic id between "0001" and "9999".
-- FYI:  map:generate_prop_id(enemy) will do the same.
--       You even can force the modification with    map:generate_prop_id(enemy, true)
-- enemy:set_id("my_id")  will set a string id named "my_id". Equivalent to   enemy:set_property("id", "my_id").
-- enemy:set_id(0001)   will set "1" without "000". So prefer a string like this:  enemy:set_id("0001").
function enemy_meta:set_id(id)

  if (id == nil) then
    self:get_map():generate_prop_id(self)
  else
    if (type(id) == "number") then
      self:set_property("id", tostring(id))
    elseif (type(id) == "string") then
      self:set_property("id", id)
    else
      error("Error with 'id' in function 'enemy_meta:set_id(id)' (number or string expected, got " .. type(id) .. ")", 2)
    end    
  end
end

return true
