local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_lantern")
end

function item:on_obtained()
  local map = game:get_map()
  map:set_darkness_level(map:get_darkness_level())
end
