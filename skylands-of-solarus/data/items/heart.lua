-- Lua script of item "heart".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

local game = item:get_game()


-- Event called when the game is initialized.
function item:on_created()

  item:set_shadow(nil)
  item:set_can_disappear(true)
  item:set_brandish_when_picked(false)
  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished(nil)

end



-- Event called when the hero gets this item.
function item:on_obtaining(variant, savegame_variable)


    local map = item:get_map()
    local hero = map:get_hero()

    if hero:get_state() == "treasure" then
      local x_hero,y_hero, layer_hero = hero:get_position()
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
      sprite:set_animation("heart")
      sprite:set_direction(0)
      sprite:set_ignore_suspend(true)
    end

    ------------------
    --  Add life
    ------------------
    game:add_life(4) -- One heart
    -- Sound
    if game:get_life() == game:get_max_life() then
      sol.audio.play_sound("items/get_item")
    end


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



-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  if pickable:get_falling_height() ~= 0 then
    -- Replace the default falling movement by a special one.
    local random = math.random(0, 1)
    local trajectory = {}
    if random == 0 then
       trajectory = {
        { 0,  0},
        { 0, -2},
        { 0, -2},
        { 0, -2},
        { 0, -2},
        { 0, -2},
        { 0,  0},
        { 0,  0},
        { 1,  1},
        { 1,  1},
        { 1,  0},
        { 1,  1},
        { 1,  1},
        { 0,  0},
        {-1,  0},
        {-1,  1},
        {-1,  0},
        {-1,  1},
        {-1,  0},
        {-1,  1},
        { 0,  1},
        { 1,  1},
        { 1,  1},
        {-1,  0}
      }
    else
      trajectory = {
        { 0,  0},
        { 0, -2},
        { 0, -2},
        { 0, -2},
        { 0, -2},
        { 0, -2},
        { 0,  0},
        { 0,  0},
        {-1,  1},
        {-1,  1},
        {-1,  0},
        {-1,  1},
        {-1,  1},
        { 0,  0},
        { 1,  0},
        { 1,  1},
        { 1,  0},
        { 1,  1},
        { 1,  0},
        { 1,  1},
        { 0,  1},
        {-1,  1},
        {-1,  1},
        { 1,  0}
      }
    end
    local m = sol.movement.create("pixel")
    m:set_trajectory(trajectory)
    m:set_delay(100)
    m:set_loop(false)
    m:set_ignore_obstacles(true)
    m:start(pickable)
    local sprite = pickable:get_sprite()
    sprite:set_animation("heart_falling")
    sprite:set_direction(random)
    -- Shadow
    local shadow_sprite = pickable:create_sprite("entities/shadow")
    pickable:bring_sprite_to_back(shadow_sprite)
    local step = 0
    function sprite:on_frame_changed(animation, frame)
      if animation == "heart_falling" then
        if frame >= 0 and step == 0 then
          shadow_sprite:set_animation("smallest")
          shadow_sprite:set_xy(0, 8)
          step = 1
        elseif frame >= 8 and step == 1 then
          shadow_sprite:set_xy(0, 6)
          step = 2
        elseif frame >= 16 and step == 2 then
          shadow_sprite:set_xy(0, 4)
          step = 3
        elseif frame >= 22 and step == 3 then
          shadow_sprite:set_animation("small")
          shadow_sprite:set_xy(0, 2)
          sprite:set_frame_delay(300)
          step = 4
        end
      end
    end
  end
end
