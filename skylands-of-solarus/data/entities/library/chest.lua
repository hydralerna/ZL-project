-- Lua script of custom entity chest.
-- This script is executed every time a custom entity with this model is created.
-- By MetalZelda (http://forum.solarus-games.org/index.php/topic,971.0.html)
-- Some changes by froggy77

local entity = ...
entity.data = {}
local game = entity:get_game()
local hero = game:get_hero()



function entity:set_treasure(item_name, variant, savegame_variable)

  local x, y, layer = entity:get_position()
  local custom_id = "x" .. x .. "y" .. y .. "l" .. layer
  entity.data.item_name = item_name
  entity.data.variant  = variant
  entity.data.savegame_variable = savegame_variable
  -- print("item_name: " .. item_name .. ", variant: " .. variant)
  if savegame_variable == nil then
    entity.data.savegame_variable = "chest_" .. entity:get_map():get_id():gsub("/", "_") .. "_" .. custom_id
  end

end
     


function entity:is_open()

  return game:get_value(entity.data.savegame_variable)

end


     
function entity:create()

  entity:set_drawn_in_y_order(false)
  entity:set_can_traverse("hero", false)
  entity:set_traversable_by("hero", false)
  entity:set_traversable_by("enemy", false)
  entity:set_traversable_by("npc", false)
  entity:set_traversable_by("custom_entity", false)
     
  if entity:is_open() then
    entity:get_sprite():set_animation("open")
    return
  end
      
  -- Hud notification
  entity:add_collision_test("facing", function(_, other)
    if other:get_type() == "hero" then 
      if not entity:is_open() then
        entity.action_effect = other:get_direction() == entity:get_direction() and "open" or "look"
      else
        entity:clear_collision_tests()
      end
    end
  end)

end



function entity:on_interaction()

  -- This is where you will play your animation, set the savegame value to true and give the hero the treasure
  -- savegame value is stored in entity.data.savegameS
  if entity:is_open() then 
    return 
  end

  if hero:get_direction() == 1 then
    hero:freeze()
    game:set_pause_allowed(false)
    entity:get_sprite():set_animation("opening", function()
      entity:get_sprite():set_animation("open")
      hero:start_treasure(entity.data.item_name, entity.data.variant, entity.data.savegame_variable, function()
        -- After the treasure has been obtained
        hero:unfreeze()
        game:set_pause_allowed(true)
      end)
    end)
       
    entity.action_effect = nil
  end

end
