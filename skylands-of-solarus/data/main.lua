-- Main Lua script of the quest.
-- See the Lua API! http://www.solarus-games.org/doc/latest

require("scripts/features")
require("scripts/multi_events")

-- Edit scripts/menus/initial_menus_config.lua to add or change menus before starting a game.
local game_manager = require("scripts/game_manager")
local shader_manager = require("scripts/shader_manager")
-- local util = require("scripts/util")
local info_manager = require("scripts/info_manager")
local index_palette_shader = require("scripts/index_palette_shader")
local palette_menu = require("scripts/menus/pause/palette_menu")
-- local console = require("scripts/console")
local sword_menu = require("scripts/menus/sword_menu")
local initial_menus_config = require("scripts/menus/initial_menus_config")
local initial_menus = {}

-- This function is called when Solarus starts.
function sol.main:on_started()

  sol.main.load_settings()
  math.randomseed(os.time())


  index_palette_shader:set_palette()
  
  -- Show the initial menus.
  if #initial_menus_config == 0 then
    return
  end

  for _, menu_script in ipairs(initial_menus_config) do
    initial_menus[#initial_menus + 1] = require(menu_script)
  end

  local on_top = false  -- To keep the debug menu on top.
  sol.menu.start(sol.main, initial_menus[1], on_top)
  for i, menu in ipairs(initial_menus) do
    function menu:on_finished()
      if sol.main.get_game() ~= nil then
        -- A game is already running (probably quick start with a debug key).
        return
      end
      local next_menu = initial_menus[i + 1]
      if next_menu ~= nil then
        sol.menu.start(sol.main, next_menu)
      end
    end
  end

  -- Set default settings for "index_palette_shader" if there is no "palette.dat"
  local default_settings = {
	palette_id = 1,
	shift = 0,
	screenScale = 2,
  }
  info_manager:create_sol_file("palette.dat", default_settings)


  -- Set "index_palette_shader" to the camera
  --local game_meta = sol.main.get_metatable("game")
  --local game_meta = sol.main.get_metatable"game"
  --function game_meta:on_map_changed()
    --local camera_surface = self:get_map():get_camera():get_surface()
	--index_palette_shader:set_palette(camera_surface)
  --end


  local game_meta = sol.main.get_metatable("game")
  game_meta:register_event("on_started", function(game)
  -- Skip initial menus when a game starts.
    for _, menu in ipairs(initial_menus) do
      sol.menu.stop(menu)
    end
  end)
end

-- Event called when the program stops.
function sol.main:on_finished()

  sol.main.save_settings()
end

local eff_m = require('scripts/maps/effect_manager')
local gb = require('scripts/maps/gb_effect')


-- Event called when the player pressed a keyboard key.
function sol.main:on_key_pressed(key, modifiers)

  local handled = false

  if key == "f5" then
	local game = sol.main.get_game()
  -- F5: change the video mode.
  -- shader_manager:switch_shader()
    if sol.menu.is_started(palette_menu) then
      sol.menu.stop(palette_menu)
      --sol.video.set_shader(nil)
      index_palette_shader:set_palette()
  	  if game and not sol.menu.is_started(sword_menu) then
        game:set_paused(false)
      end
  	else
		  sol.video.set_shader(nil)
      --local camera = sol.main.get_game():get_map():get_camera()
      --local map = sol.main.get_game():get_map()
      --local hero = map:get_hero()
      --camera:start_tracking(hero)
      --local camera_surface = sol.main.get_game():get_map():get_camera():get_surface()
      --camera_surface:clear()
		  sol.menu.start(sol.main, palette_menu)
		  if game then
			 game:set_paused(true)
		  end
    end

  elseif key == "f6" then
	local game = sol.main.get_game()
    if not sol.menu.is_started(palette_menu) then
      if sol.menu.is_started(sword_menu) then
        sol.menu.stop(sword_menu)
        index_palette_shader:set_palette()
  	   if game and not sol.menu.is_started(sword_menu) then
          game:set_paused(false)
        end
  	 else
		    sol.video.set_shader(nil)
		    sol.menu.start(sol.main, sword_menu)
		    if game then
			   game:set_paused(true)
		    end
      end
    end

  elseif key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    handled = true
  -- elseif key == "f12" and not console.enabled then
    -- sol.menu.start(sol.main, console)
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.get_game() == nil then
    -- Escape in pre-game menus: stop the program.
    sol.main.exit()
    handled = true
  end

  return handled
end
