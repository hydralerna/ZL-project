-- Initialize Map behavior specific to this quest.

-- Variables
local map_meta = sol.main.get_metatable("map")

-- Include scripts
require ("scripts/multi_events")

-- Set the camera size to avoid problems with the hud
map_meta:register_event("on_started", function(map)

  local camera = map:get_camera()
  camera:set_position_on_screen(72, 40)
  camera:set_size(240, 160)
end)
