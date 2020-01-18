-- Bombs item.
local item = ...

local game = item:get_game()

function item:on_created()

  self:set_savegame_variable("possession_bomb")
  self:set_assignable(true)
  self:set_brandish_when_picked(false)
end

function item:on_obtaining()
  -- Automatically assign the item to a command slot
  -- because it is the only existing item for now.
  game:set_item_assigned(1, self)
end

-- Called when the player uses the bombs of his inventory by pressing
-- the corresponding item key.
function item:on_using()

  local hero = self:get_map():get_entity("hero")
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

  self:get_map():create_bomb{
    x = x,
    y = y,
    layer = layer,
    -- properties = {{key = "test", value = "3",}, {key = "essai", value = "8",}}
  }

  self:set_finished()
end

