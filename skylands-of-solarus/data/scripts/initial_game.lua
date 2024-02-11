-- This script initializes game values for a new savegame file.
-- You should modify the initialize_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialize_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialize_new_savegame(game)

  -- You can modify this function to set the initial life and equipment
  -- and the starting location.
  local map_id = "Tests/test_map"
  game:set_starting_location(map_id, nil)  -- Starting location.

  game:set_value("submenu_theme", 1)
  game:set_value("submenu_bg_icon_sprite", 1)
  game:set_value("cursor_row", 0)
  game:set_value("cursor_column", 1)
  game:set_max_life(12)
  game:set_life(game:get_max_life())
  game:set_max_magic(24)
  game:set_life(game:get_max_magic())
  -- TEST game:set_value("possession_coin_bag", 1)
  -- TEST game:set_max_money(10)
  game:set_money(1)
  game:set_value("max_rupee", 12)
  game:set_value("current_rupee", 3)
  game:set_ability("lift", 1)
  game:set_ability("sword", 1)
  game:set_value("player_name", "Link")
end

return initial_game
