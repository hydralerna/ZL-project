-- Lua script of map Morla.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()


-- Include scripts
require("scripts/multi_events")


-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  count = 0
  
  function collapse_sensor:on_activated()

    local count = 0
    sol.audio.play_sound("misc/dungeon_shake")
    hero:freeze()
    hero:set_direction(0)
    hero:set_animation("walking")
    local m = sol.movement.create("straight")
    m:set_angle(0)
    m:set_speed(hero:get_walking_speed())
    m:set_max_distance(80)
    m:start(hero, function()
      map:remove_entities("morla_hill_")
      hero:set_direction(2)
      hero:set_animation("stopped")
    end)
    sol.timer.start(map, 1000, function()
       sol.audio.play_sound("misc/dungeon_shake")
       count = count + 1
       if count < 8 then
          return true
       else
          hero:unfreeze()
       end
    end)

  end

end)


function hero:on_state_changed(new_state_name)

  local map_morla = game:get_value("map_morla")
  local distance = hero:get_distance(rock)
  if new_state_name == "sword tapping" and distance <= 24 then
    count = count + 1
    --print(count)
    if map_morla == nil and count == 3 then
        game:set_value("map_morla", 0)
        count = 0
        game:start_dialog("maps.out.morla.allergy")
    elseif map_morla == 0 and count == 2 then
        count = 0
        game:start_dialog("maps.out.morla.0.waking_up_2")
    end
  elseif new_state_name == "sword tapping" and distance > 24 and count > 0 then
    count = 0
  end  

end


function rock:on_interaction()

  local map_morla = game:get_value("map_morla")
  if map_morla == nil then
    game:start_dialog("maps.out.morla.0.hero_calling_1")
  elseif map_morla == 0 then 
    game:start_dialog("maps.out.morla.0.question", game:get_player_name())
  end
end


function rock_2:on_interaction()

  local map_morla = game:get_value("map_morla")
  if map_morla == nil then
    game:start_dialog("maps.out.morla.0.hero_calling_1")
  elseif map_morla == 0 then 
    game:start_dialog("maps.out.morla.0.question")
  end
end


--function morla_step1()
--  local sprite_morla = morla:get_sprite()
--  sol.timer.start(map, 500, function()
--    sprite_morla:set_direction(3)
--    sprite_morla:set_animation("appearingO")
--  end)
--end

--function morla_step1()
--  local sprite_morla = morla:get_sprite()
--  sol.timer.start(map, 500, function()
--    sprite_morla:set_direction(3)
--    sprite_morla:set_animation("appearing1")
--  end)
--end

--function morla_step2()
--  local sprite_morla = morla:get_sprite()
--  sol.timer.start(map, 1620, function()
--    sprite_morla:set_direction(3)
--    sprite_morla:set_animation("appearing2")
--  end)
--  game:start_dialog("morla2", function(answer)
--    if answer == 1 then
--        morla_step3()
--    end
--  end)
--end

--function morla_step3()
--  local sprite_morla = morla:get_sprite()
--  sol.timer.start(map, 500, function()
--    sprite_morla:set_direction(3)
--    sprite_morla:set_animation("appearing3")
--  end)
--end



