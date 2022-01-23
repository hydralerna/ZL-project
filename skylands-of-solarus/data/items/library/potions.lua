-- Lua script of item library/potions.
-- This script is executed only once for the whole game.
-- It handles all potions (each potion script runs it).

return function(item)

  local game = item:get_game()
  local item_name = item:get_name()
  local save_name  = item_name:gsub("/", "_")



  -- Event called when the game is initialized.
  function item:on_created()

    item:set_savegame_variable("possession_" .. save_name)
    item:set_amount_savegame_variable("amount_" .. save_name)
    item:set_max_amount(3)
    item:set_assignable(true)
    item:set_shadow("small")
    item:set_can_disappear(true)
    item:set_brandish_when_picked(false)
    item:set_sound_when_picked(nil)
    item:set_sound_when_brandished(nil)
    
  end



  -- Event called when the hero gets this item.
  function item:on_obtaining(variant, savegame_variable)

    local map = item:get_map()
    local hero = map:get_hero()

    ------------------
    --  Add potion
    ------------------
    local function add_potion()

      item:add_amount(1)
      game:set_item_assigned(1, item)

    end

    if hero:get_state() == "treasure" then
      local x_hero,y_hero, layer_hero = hero:get_position()
      hero:freeze()
      hero:set_animation("brandish")
      sol.audio.play_sound("items/fanfare_item")
      local potion_entity = map:create_custom_entity({
        name = "brandish",
        sprite = "entities/items",
        x = x_hero,
        y = y_hero - 13,
        width = 16,
        height = 16,
        layer = layer_hero + 1,
        direction = 1
        })
      local sprite = potion_entity:get_sprite()
      sprite:set_animation(item_name .. "_falling")
      sprite:set_direction(1)
      game:start_dialog("_treasure." .. save_name .. ".1", function()
        add_potion()
        hero:set_animation("stopped")
        map:remove_entities("brandish")
        hero:unfreeze()
      end)
    else
      add_potion()
      sol.audio.play_sound("items/get_rupee")
    end

    
  end



  -- Event called when a pickable treasure representing this item
  -- is created on the map.
  function item:on_pickable_created(pickable)

    local sprite = pickable:get_sprite()
    local shadow_sprite = pickable:get_sprite("shadow")
    -- The potion is on the ground. It did not fall. 
    if pickable:get_falling_height() == 0 then
      shadow_sprite:set_xy(0, 3)
    -- The potion is falling. The animation is different to show that the content is unstable and will disappear.
    else
      local name_falling = item_name .. "_falling"
      local count = 0
      while count < 16 do
        count = count + 1
        if count == 16 then
          sprite:set_animation(name_falling)
          shadow_sprite:set_xy(0, 3)
        end
      end
    end

  end



  -- Event called when the hero starts using this item.
  function item:on_using()

    local variant = item:get_variant()
    local map = item:get_map()

    ------------------
    --  Remove potion
    ------------------
    local function remove_potion()

      item:remove_amount(1)
      sol.audio.play_sound("hero/wade2") -- Sound of the bottle that the hero uncorks

    end
    ------------------
    --  No more potions
    ------------------
    if item:get_amount() == 0 then
      sol.audio.play_sound("misc/error")
    else
      if  variant == 1 then
        ------------------
        --  Empty potion
        ------------------
        game:start_dialog("item_empty_potion")
      else
        ------------------
        --  Life potion
        ------------------
        if item_name == "potions/life_potion" then
          if game:get_life() == game:get_max_life() then
              game:start_dialog("item_life_potion_not_needed")
          else
            remove_potion()
            local amounts = {3, 5, 7} -- Hearts
            game:add_life(amounts[variant - 1] * 4)
          end
        ------------------
        --  Healing potion
        ------------------
        elseif item_name == "potions/healing_potion" then
          if game:get_life() == game:get_max_life() and game:get_magic() == game:get_max_magic() then
            game:start_dialog("item_healing_potion_not_needed")
          else
            remove_potion()
            local rate = 3000
            local durations = {36000, 60000, 84000} -- One heart every 12 seconds. So 3, 5, 7 hearts, idem for magic
            local duration = durations[variant - 1]
            local elapsed_time = 0
            sol.timer.start(game, rate, function()
              elapsed_time = elapsed_time + rate
              game:add_life(1)
              game:add_magic(1)
              if elapsed_time < duration then
                return true
              end
            end)
          end
        ------------------
        --  Magic potion
        ------------------
        elseif item_name == "potions/magic_potion" then
          if game:get_magic() == game:get_max_magic() then
              game:start_dialog("item_magic_potion_not_needed")
          else
            remove_potion()
            local amounts = {3, 5, 7} -- Magic
            game:add_magic(amounts[variant - 1] * 4)
          end
        end
      end
    end
    --item:set_variant(1) -- Make the flask empty
    item:set_finished()
  end


end

