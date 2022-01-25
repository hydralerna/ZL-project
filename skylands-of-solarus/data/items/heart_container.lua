-- Lua script of item "heart container".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()

  item:set_brandish_when_picked(false)
  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished(nil)

end



function item:on_obtaining()
  
  local map = item:get_map()
  local hero = map:get_entity("hero")
  local x_hero,y_hero, layer_hero = hero:get_position()
  hero:freeze()
  hero:set_animation("brandish")
  sol.audio.play_sound("items/fanfare_heart_container")
  local custom_entity = map:create_custom_entity({
    name = "brandish",
    sprite = "entities/items",
    x = x_hero,
    y = y_hero - 13,
    width = 16,
    height = 16,
    layer = layer_hero + 1,
    direction = 0
    })
  local sprite = custom_entity:get_sprite()
  sprite:set_animation("heart_container")
  sprite:set_direction(0)
  sprite:set_ignore_suspend(true)
       
end



function item:on_obtained(variant)

  local map = item:get_map()
  local hero = map:get_entity("hero")
  local sprite = hero:get_sprite()
  game:add_max_life(4)
  game:set_life(game:get_max_life())
  hero:set_animation("stopped")
  sprite:set_ignore_suspend(false)
  map:remove_entities("brandish")
  hero:unfreeze()

end