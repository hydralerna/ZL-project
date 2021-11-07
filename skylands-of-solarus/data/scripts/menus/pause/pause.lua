-- Script that creates a pause menu for a game.

-- Usage:
-- require("scripts/menus/pause/pause")

require("scripts/multi_events")
local audio_manager = require("scripts/audio_manager")

-- Creates a pause menu for the specified game.
local function initialize_pause_features(game)

  if game.pause_menu ~= nil then
    -- Already done.
    return
  end

  local inventory_builder = require("scripts/menus/pause/pause_inventory")
  local palette_menu = require("scripts/menus/pause/palette_menu")
  --local map_builder = require("scripts/menus/pause/pause_map")
  --local quest_builder = require("scripts/menus/pause/pause_quest")
  --local options_builder = require("scripts/menus/pause/pause_options")

  local pause_menu = {}
  game.pause_menu = pause_menu

  -- Starts the pause menu.
  function pause_menu:open()
    sol.menu.start(game, pause_menu, true)
  end

  -- Stops the pause menu.
  function pause_menu:close()
    sol.menu.stop(pause_menu)
  end

  -- Called when the pause menu is started.
  function pause_menu:on_started()

    -- Define the available submenus.

    -- Array of submenus (inventory, map, etc.).
    game.pause_submenus = {
      inventory_builder:new(game),
      palette_menu:new(game),
      --map_builder:new(game),
      --quest_builder:new(game),
      --options_builder:new(game),
    }

    -- Select the submenu that was saved if any.
    local submenu_index = game:get_value("pause_last_submenu") or 1
    if submenu_index <= 0
        or submenu_index > #game.pause_submenus then
      submenu_index = 1
    end
    game:set_value("pause_last_submenu", submenu_index)

    -- Play the sound of pausing the game.
    audio_manager:play_sound("menus/pause_menu_open")

    -- Forces the dialog_box to be at bottom.
    --local dialog_box = game:get_dialog_box()
    --self.backup_dialog_position = dialog_box:get_position()
    --dialog_box:set_position("bottom")
    
    -- Set the HUD correct mode.
    pause_menu.backup_hud_mode = game:get_hud_mode()
    game:set_hud_mode("pause")

    -- Start the selected submenu.
    sol.menu.start(pause_menu, game.pause_submenus[submenu_index])
  end

  -- Called when the pause menu is stopped.
  function pause_menu:on_finished()

    -- Play the sound of unpausing the game.
    audio_manager:play_sound("menus/pause_menu_close")

    -- Clear the submenus table.
    game.pause_submenus = {}
    
    -- Restore the dialog_box position.
    --game:get_dialog_box():set_position(self.backup_dialog_position)
    
    -- Restore the HUD mode.
    game:set_hud_mode(pause_menu.backup_hud_mode)

    -- Restore the built-in effect of action and attack commands.
    if game.set_custom_command_effect ~= nil then
      game:set_custom_command_effect("action", nil)
      game:set_custom_command_effect("attack", nil)
    end
  end

  -- Automatically starts the pause menu when the game is set on pause.
  game:register_event("on_paused", function(game)
    pause_menu:open()
  end)

  -- Automatically stops the pause menu when the game is unpaused.
  game:register_event("on_unpaused", function(game)
    pause_menu:close()
  end)

end

-- Set up the pause menu on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_pause_features)

return true
