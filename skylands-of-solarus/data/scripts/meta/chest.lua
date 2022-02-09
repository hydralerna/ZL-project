-- Initialize behavior of chests in this quest.
-- By MetalZelda (http://forum.solarus-games.org/index.php/topic,971.0.html)

require("scripts/multi_events")

local chest_meta = sol.main.get_metatable("chest")
     
function chest_meta:on_created()

  local item_name, variant, savegame_var = self:get_treasure()
  local x, y, layer = self:get_position()
  local graphic = self:get_sprite():get_animation_set() 
  local setup = {
        x = x,
        y = y,
        layer = layer,
        model = "library/chest",
        width = 16,
        height = 16,
        direction = 1,
        sprite = graphic
  }
  local entity = self:get_map():create_custom_entity(setup)
  entity:set_treasure(item_name, variant, savegame_var)
  entity:create()

  -- You might need to customize this chest.
  function self:get_chest()

    return entity
  end
  self:remove()
end