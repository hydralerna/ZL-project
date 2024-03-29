-- Lua script of item "coin".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

-- Event called when the game is initialized.
function item:on_created()

  item:set_shadow("small")
  item:set_can_disappear(true)
  item:set_brandish_when_picked(false)
  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished(nil)
  
end



-- Event called when the hero gets this item.
function item:on_obtaining(variant, savegame_variable)

  local map = item:get_map()
  local hero = map:get_hero()
  local amounts = {1, 5, 10}
  local amount = amounts[variant]

  if hero:get_state() == "treasure" then
    local x_hero,y_hero, layer_hero = hero:get_position()
    hero:freeze()
    hero:set_animation("brandish")
    sol.audio.play_sound("items/fanfare_item")
    local custom_entity = map:create_custom_entity({
      name = "brandish",
      sprite = "entities/items",
      x = x_hero,
      y = y_hero - 15,
      width = 16,
      height = 16,
      layer = layer_hero + 1,
      direction = 0
     })
     local sprite = custom_entity:get_sprite()
     sprite:set_animation("coin")
     sprite:set_direction(variant - 1)
     sprite:set_ignore_suspend(true)
  end

  ------------------
  --  Add money
  ------------------
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'coin'")
  end
  sol.audio.play_sound("items/get_rupee")
  item:get_game():add_money(amount)

end



function item:on_obtained(variant)

  local map = item:get_map()
  local hero = map:get_hero()
  if hero:get_state() == "frozen" then
    local sprite = map:get_entity("brandish"):get_sprite()
    hero:set_animation("stopped")
    sprite:set_ignore_suspend(false)
    map:remove_entities("brandish")
    hero:unfreeze()
  end

end



-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  local shadow_sprite = pickable:get_sprite("shadow")
  if pickable:get_falling_height() == 0 then
    shadow_sprite:set_xy(0, 3)
  else
    local sprite = pickable:get_sprite()
    sprite:set_animation("coin_falling")
    local count = 0
    function sprite:on_frame_changed(animation, frame)
      count = count + 1
      if animation == "coin_falling" and count >= 16 then
        sprite:set_animation("coin")
        sprite:set_frame(frame)
        shadow_sprite:set_xy(0, 3)
      end
    end
  end

end
