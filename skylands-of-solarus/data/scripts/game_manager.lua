-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

require("scripts/multi_events")
local initial_game = require("scripts/initial_game")

local game_manager = {}

-- Creates a game ready to be played.
function game_manager:create(file)

  -- Create the game (but do not start it).
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  if not exists then
    -- This is a new savegame file.
    initial_game:initialize_new_savegame(game)
  end

  function game:get_player_name()

    local name = self:get_value("player_name")
    local hero_is_thief = game:get_value("hero_is_thief")
    if hero_is_thief then
      name = sol.language.get_string("game.thief")
    end
    return name
  end

  function game:set_player_name(player_name)
    self:set_value("player_name", player_name)
  end

  return game
end

return game_manager
