-- Lua script of item "heart".
-- This script is executed only once for the whole game.

-- Variables
local item = ...

-- Event called when the game is initialized.
function item:on_created()

  item:set_shadow(nil)
  item:set_can_disappear(true)
  item:set_brandish_when_picked(false)
  item:set_sound_when_picked(nil) 

end


function item:on_obtaining(variant, savegame_variable)

  -- Sound
  if item:get_game():get_life() == item:get_game():get_max_life() then
    sol.audio.play_sound("items/get_item")
  else
    -- Life
    item:get_game():add_life(4)
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
    local step = 0
    function sprite:on_frame_changed(animation, frame)
      if animation == "heart_falling" then
        if frame >= 0 and step == 0 then
          shadow_p_sprite = pickable:create_sprite("entities/shadow")
          pickable:bring_sprite_to_back(shadow_p_sprite)
          shadow_p_sprite:set_animation("smallest")
          shadow_p_sprite:set_xy(0, 8)
          step = 1
        elseif frame >= 8 and step == 1 then
          shadow_p_sprite:set_xy(0, 6)
          step = 2
        elseif frame >= 16 and step == 2 then
          shadow_p_sprite:set_xy(0, 4)
          step = 3
        elseif frame >= 22 and step == 3 then
          shadow_p_sprite:set_animation("small")
          shadow_p_sprite:set_xy(0, 2)
          sprite:set_frame_delay(300)
          step = 4
        end
      end
    end
  end --(endif pickable:get_falling_height())

end