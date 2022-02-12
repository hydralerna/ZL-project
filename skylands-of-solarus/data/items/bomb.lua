-- Bombs item.
local item = ...

local game = item:get_game()
local item_name = item:get_name()

function item:on_created()

  item:set_savegame_variable("possession_" .. item_name)
  item:set_amount_savegame_variable("amount_" .. item_name)
  item:set_max_amount(10)
  item:set_assignable(true)
  item:set_shadow("small")
  item:set_can_disappear(true)
  item:set_brandish_when_picked(false)
  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished(nil)

end

function item:on_obtaining(variant)

  local map = item:get_map()
  local hero = map:get_hero()
  local amounts = {1, 3, 5, 8}
  local amount = amounts[variant]

  if hero:get_state() == "treasure" then
    local x_hero, y_hero, layer_hero = hero:get_position()
    hero:freeze()
    hero:set_animation("brandish")
    sol.audio.play_sound("items/fanfare_item")
    local custom_entity = map:create_custom_entity({
      name = "brandish",
      sprite = "entities/items",
      x = x_hero,
      y = y_hero - 15,
      width = 16,
      height = 16,
      layer = layer_hero + 1,
      direction = 0
      })
    local sprite = custom_entity:get_sprite()
    sprite:set_animation(item_name .. "_falling")
    sprite:set_direction(0)
    sprite:set_ignore_suspend(true)
  end
  ------------------
  --  Add bomb
  ------------------
  item:add_amount(amount)
  -- Automatically assign the item to a command slot
  -- because it is the only existing item for now.
  game:set_item_assigned(1, item)
  sol.audio.play_sound("items/get_rupee")
  
end


function item:on_obtained(variant)

    local map = item:get_map()
    local hero = map:get_hero()
    if hero:get_state() == "frozen" then
      local sprite = map:get_entity("brandish"):get_sprite()
      hero:set_animation("stopped")
      sprite:set_ignore_suspend(false)
      map:remove_entities("brandish")
      hero:unfreeze()
    end

end

-- Called when the player uses the bombs of his inventory by pressing
-- the corresponding item key.
function item:on_using()

  ------------------
  --  No more bombs
  ------------------
  if item:get_amount() == 0 then
    sol.audio.play_sound("misc/error")
  ------------------
  --  Bomb
  ------------------
  else
    local hero = item:get_map():get_entity("hero")
    local x, y, layer = hero:get_position()
    local direction = hero:get_direction()
    if direction == 0 then
      x = x + 16
      y = y - 5
    elseif direction == 1 then
      y = y - 16
    elseif direction == 2 then
      x = x - 16
      y = y - 5
    elseif direction == 3 then
      y = y + 11
    end

    item:get_map():create_bomb{
      x = x,
      y = y,
      layer = layer,
      -- properties = {{key = "test", value = "3",}, {key = "essai", value = "8",}}
    }
    ------------------
    --  Remove bomb
    ------------------
    item:remove_amount(1)
  end
  item:set_finished()

end



-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  local sprite = pickable:get_sprite()
  local shadow_sprite = pickable:get_sprite("shadow")
  -- The bomb is on the ground. It did not fall. 
  if pickable:get_falling_height() == 0 then
    shadow_sprite:set_xy(0, 2)
  -- The bomb is falling.
  else
    local name_falling = item_name .. "_falling"
    local count = 0
    while count < 16 do
      count = count + 1
      if count == 16 then
        sprite:set_animation(name_falling)
        shadow_sprite:set_xy(0, 2)
      end
    end
  end

end