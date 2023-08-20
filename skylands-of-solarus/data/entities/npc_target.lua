-- Lua script of custom entity npc_target.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest


local entity = ...
local game = entity:get_game()


-- Event called when the custom entity is initialized.
function entity:on_created()
  
  entity:set_can_traverse("hero", true)
  entity:set_traversable_by("hero", true)
  entity:set_traversable_by("enemy", true)
  entity:set_traversable_by("npc", true)
  entity:set_traversable_by("custom_entity", true)
  entity:set_size(16, 16)

end