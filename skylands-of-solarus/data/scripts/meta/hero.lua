local hero_meta = sol.main.get_metatable("hero")

require ("scripts/multi_events")
local tbl_offset = {{x = 1 , y = 0}, {x = 0 , y = -3}, {x = -1 , y = 0}, {x = 0 , y = -5}}


hero_meta:register_event("on_position_changed", function(hero, x, y, layer)

  local map = hero:get_map()
  local index = hero:get_direction() + 1
  grid_id = map:get_grid_id(x + tbl_offset[index].x, y + tbl_offset[index].y)
  --print("grid_id (hero:on_position_changed)", grid_id, x, y, tbl_offset[index].x, tbl_offset[index].y)

end)