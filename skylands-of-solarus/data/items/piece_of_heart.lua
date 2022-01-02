-- Lua script of item "piece of heart".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()

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
  
  -- Sound
  sol.audio.play_sound("items/fanfare_item")
        
end

function item:on_obtained(variant)

  local num_pieces_of_heart = item:get_num_pieces_of_heart()
  game:set_value("num_pieces_of_heart", (num_pieces_of_heart + 1) % 4)
  game:set_value("total_pieces_of_heart", item:get_total_pieces_of_heart() + 1)
  if num_pieces_of_heart == 0 then
    game:start_dialog("_treasure.piece_of_heart.2")
  elseif num_pieces_of_heart == 1 then
    game:start_dialog("_treasure.piece_of_heart.3")
  elseif num_pieces_of_heart == 2 then
    game:start_dialog("_treasure.piece_of_heart.4")
  else
    game:start_dialog("_treasure.piece_of_heart.5", function()
        game:add_max_life(4)
        game:set_life(game:get_max_life())
    end)
  end
  game:add_life(game:get_max_life())

end
