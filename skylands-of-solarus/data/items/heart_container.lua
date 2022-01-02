-- Lua script of item "heart container".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

-- Event called when the game is initialized.
function item:on_created()

  self:set_sound_when_picked(nil)
  self:set_brandish_when_picked(false)

end

function item:on_obtained(variant, savegame_variable)

  local map = self:get_map()
  local hero = map:get_entity("hero")
  local x_hero,y_hero, layer_hero = hero:get_position()
  hero:freeze()
  hero:set_animation("brandish")
  sol.audio.play_sound("items/fanfare_heart_container")
  local heart_container_entity = map:create_custom_entity({
    name = "brandish",
    sprite = "entities/items",
    x = x_hero,
    y = y_hero - 13,
    width = 16,
    height = 16,
    layer = layer_hero + 1,
    direction = 0
    })
  local sprite = heart_container_entity:get_sprite()
  sprite:set_animation("heart_container")
  sprite:set_direction(0)
  local game = self:get_game()
  game:start_dialog("_treasure.heart_container.1", function()
    game:add_max_life(4)
    game:set_life(game:get_max_life())
    hero:set_animation("stopped")
    map:remove_entities("brandish")
    hero:unfreeze()
  end)

end

