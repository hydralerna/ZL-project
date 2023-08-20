local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()



-- Include scripts
require("scripts/multi_events")

-- Event called when the custom entity is initialized.
entity:register_event("on_created", function()

  print("TEST CUSTOM POT: created")
  entity:snap_to_grid()
  entity:set_traversable_by("hero", false)
  --entity:set_can_traverse("hero", true)
  entity:set_weight(0)
  entity:set_property("property", "pot")


  entity:add_collision_test("facing", function(_, other)
    if other:get_type() == "hero" then
      if entity:get_property("property") == "pot" then
        entity:set_property("property", "block")
        print(entity:get_property("property"))
      else
        entity:set_property("property", "pot")
        print(entity:get_property("property"))
      end
      --local x_entity, y_entity = entity:get_position()
      --local x_hero, y_hero = hero:get_position()

      --local m = sol.movement.create("straight")
      --m:set_angle(hero:get_direction4_to(entity) * math.pi/2)
      --m:set_speed(16)
      --m:start(entity)
      --print("facing")
      -- hero:freeze()
      --if not touching then
        --touching = true
        --print("touching")
      --end
    end
  end)



 -- function entity:on_interaction()

 --     print("TEST CUSTOM POT: on_interaction")
 -- end

  function entity:on_lifting(carrier, carried_object)

    carried_object:get_sprite():set_xy(0, 7)
    print("TEST CUSTOM POT: on_lifting")
    function carried_object:on_thrown()

      print("TEST CUSTOM POT: on_thrown")
    end

    function carried_object:on_breaking()
      print("TEST CUSTOM POT: on_breaking")
      --local hero = map:get_hero()
      local x_entity, y_entity, layer_entity = carried_object:get_position()
      local custom_entity = map:create_custom_entity({
        name = "custom_pot",
        sprite = "destructibles/jar01",
        x = x_entity,
        y = y_entity,
        width = 16,
        height = 16,
        layer = layer_entity,
        direction = 0,
        model = "custom_pot"
        })
      local sprite = custom_entity:get_sprite()
      sprite:set_direction(0)
    end
  end


end)




-- By zhj 
-- MODIF

--[[
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local carried_object
local hero = map:get_hero()
local m = sol.movement.create("straight")
local life
local block

function entity:on_created()
  entity:set_traversable_by("hero", false)
  entity:set_weight(0)
end

function entity:on_lifting(carrier, carried_object)
  carried_object = carried_object
  if entity:get_property("block") then
    block = map:get_entity("pot")
    block:remove()
  end
  if entity:get_property("life") then
    life = tonumber(entity:get_property("life"))
  else
    life = 3
  end
  function carried_object:on_thrown()
    local x,y,layer = hero:get_position()
    local width, height = carried_object:get_size()
    local sprite = carried_object:get_sprite()
    local direction = sprite:get_direction()
    local new_e = map:create_custom_entity({layer = layer,direction = 0 ,x = x, y = y,width = width, height = height, sprite ="entities/megabomb",model ="pot"})
    if life > 0 then
      life = life - 1
      new_e:set_property("life", life)
    else
      new_e:remove()
      return
    end
    new_e:set_visible(false)
    m:set_angle(hero:get_sprite():get_direction()*math.pi/2)
    m:set_speed(200)
    m:start(new_e)
      function carried_object:on_breaking()
        m:stop()
        new_e:set_visible(true)
        local x,y,layer = new_e:get_position()
        block = map:create_block({name="pot" ,layer = layer,x = x, y = y,direction = nil ,sprite = "entities/megabomb" ,pushable = true, pullable = true})
        new_e:set_property("block", "pot")
        if hero:overlaps(new_e) then
          local x,y,layer = hero:get_position()
          local direction = hero:get_direction()
          local width, height = hero:get_size()
          new_e:set_position(x +width*math.cos(direction*math.pi/2), y -height*math.sin(direction*math.pi/2), layer)
          hero:start_grabbing()
        end
      end
  end
end
--]]