-- Lua script of item "coin bag".
-- This script is executed only once for the whole game.

-- Variables
local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_created()

  self:set_savegame_variable("possession_coin_bag")
  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished(nil)

end


-- Event called when the hero gets a different variant of this item
-- (i.e. another bag). 
function item:on_variant_changed(variant)

  -- Obtaining a coin bag changes the max amount of coins.
  local max_coins = {50, 100, 300, 500, 1000, 3000, 9999}
  local amount = max_coins[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'coin_bag'")
  end
  game:set_max_money(amount)

end


-- Event called when the hero gets this item.
function item:on_obtaining()
  
  local map = self:get_map()
  local hero = map:get_entity("hero")
  local x_hero,y_hero, layer_hero = hero:get_position()
  hero:freeze()
  hero:set_animation("brandish")
  sol.audio.play_sound("items/fanfare_item")
  local direction = self:get_variant() - 1
  local custom_entity = map:create_custom_entity({
    name = "brandish",
    sprite = "entities/items",
    x = x_hero,
    y = y_hero - 13,
    width = 16,
    height = 16,
    layer = layer_hero + 1,
    direction = direction
    })
  local sprite = custom_entity:get_sprite()
  sprite:set_animation("coin_bag")
  sprite:set_direction(direction)

end


-- Event called when the hero has obtained this item. 
function item:on_obtained(variant)

  local coin_bonus = {7, 23, 58, 91, 173, 0, 856, 2485}
  game:add_money(coin_bonus[variant])
  local map = self:get_map()
  local hero = map:get_hero("hero")
  hero:set_animation("stopped")
  map:remove_entities("brandish")
  hero:unfreeze()

end
