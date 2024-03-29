-- Lua script of item "piece of heart".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()
local item_name = item:get_name()

-- Event called when the game is initialized.
function item:on_created()

  item:set_savegame_variable("possession_" .. item_name)
  item:set_amount_savegame_variable("amount_" .. item_name)
  item:set_shadow("small")
  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished(nil)

  
end

-- Returns the current number of pieces of heart between 0 and 3.
function item:get_num_pieces_of_heart()

  return game:get_value("num_pieces_of_heart") or 0
  
end

-- Returns the total number of pieces of hearts already found.
function item:get_total_pieces_of_heart()

  return game:get_value("total_pieces_of_heart") or 0
  
end

-- Returns the number of pieces of hearts existing in the game.
function item:get_max_pieces_of_heart()

  return 12
  
end



function item:on_obtaining()
  
  local map = item:get_map()
  local hero = map:get_entity("hero")
  local x_hero,y_hero, layer_hero = hero:get_position()
  hero:freeze()
  hero:set_animation("brandish")
  sol.audio.play_sound("items/fanfare_item")
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
  sprite:set_animation(item_name)
  sprite:set_direction(0)
  sprite:set_ignore_suspend(true)

       
end



function item:on_obtained()

  local map = item:get_map()
  local hero = map:get_entity("hero")
  local sprite = hero:get_sprite()
  local num_pieces_of_heart = item:get_num_pieces_of_heart()
  local id = num_pieces_of_heart % 4 + 2
  game:set_value("num_pieces_of_heart", (num_pieces_of_heart + 1) % 4)
  game:set_value("total_pieces_of_heart", item:get_total_pieces_of_heart() + 1)
  game:start_dialog("_treasure.piece_of_heart."..id, function()
    if id == 5 then
      game:add_max_life(4)
      game:set_life(game:get_max_life())
    else
      game:add_life(game:get_max_life())
    end
  end)
  hero:set_animation("stopped")
  sprite:set_ignore_suspend(false)
  map:remove_entities("brandish")
  hero:unfreeze()

end

