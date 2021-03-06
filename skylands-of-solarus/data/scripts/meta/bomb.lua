-- Initialize Bomb behavior specific to this quest.

-- Variables
local bomb_meta = sol.main.get_metatable("bomb")

-- Include scripts
require ("scripts/multi_events")

-- Allows you to have more "directions" for the sprite, here chosen randomly.
function bomb_meta:on_created()

  local bomb = self
  -- Just a test to get a value from an array. See in /items/bomb.lua, self:get_map():create_bomb{ ...
  ----local map = bomb:get_map()
  -- local properties = bomb:get_properties()
  -- local direction = properties[1]["value"]
  -- for	k, v in pairs(properties[1]) do
  --  print(k, v)
  --end
  -- print(properties[1]["value"])
  local sprite = bomb:get_sprite()
  sprite:set_animation("stopped_on_floor")
  sprite:set_direction(math.random(0, 3))

end