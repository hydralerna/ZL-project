-- Initialize Explosion behavior specific to this quest.

-- Variables
local explosion_meta = sol.main.get_metatable("explosion")

-- Include scripts
require ("scripts/multi_events")

-- Allows you to have more "directions" for the sprite, here chosen randomly.
function explosion_meta:on_created()
  
  local explosion = self
  local sprite = explosion:get_sprite()
  --sprite:set_direction(math.random(0, 1))
  sprite:set_direction(0)
  sol.audio.play_sound("items/bomb_explode")

end

return true