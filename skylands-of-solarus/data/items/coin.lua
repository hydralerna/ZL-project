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


function item:on_obtaining(variant, savegame_variable)

  local map = item:get_map()
  local hero = map:get_hero()
  -- Sound
  if hero:get_state() == "treasure" then
    sol.audio.play_sound("items/fanfare_item")
  else
    sol.audio.play_sound("items/get_rupee")
  end
  local amounts = {1, 5, 20, 50, 100, 200}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'coin'")
  end
  item:get_game():add_money(amount)
  
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
