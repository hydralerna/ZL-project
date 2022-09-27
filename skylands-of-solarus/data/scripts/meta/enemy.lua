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


function enemy_meta:on_hurt()

  local enemy = self
  if enemy:get_life() == 0 then
    enemy:get_sprite():set_animation("dying")
  end
end

return true
