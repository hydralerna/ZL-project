-- Lua script of map test_map.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

require("scripts/multi_events")
require("scripts/ground_effects")

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()

  -- You can initialize the movement and sprites of various
  -- map entities here.



end)


function map:on_draw(dst_surface) 

  ---------------------------
  -- TEST DU SCRIPT util.lua
  ---------------------------
  local util = require"scripts/util"
  local LINE_COLOR = {143, 192, 112}

  --calculate series of rectangles needed to draw line
  local path = util.make_path(
      {x=48, y=40}, --starting coordinates
      {x=100, y=128} --ending coordinates
  )

  --draw the line on surface
  for y,row in pairs(path) do
    local x = row.start
    local width = row.stop - x + 1
    --surface:fill_color(LINE_COLOR, x, y, width, 20)
    dst_surface:fill_color(LINE_COLOR, x, y, width, 20)
  end
  ---------------------------




end


-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
