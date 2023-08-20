-- Lua script of map test_map.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

require("scripts/multi_events")
require("scripts/ground_effects")


local map = ...
local game = map:get_game()
local hero = map:get_hero()
local map_width, map_height = map:get_size()
local t_torches = map:create_table_lights()

-- List for testing
--[[
for tk, tv in pairs(t_torches) do
  print(tk, tv)
  for k, v in pairs(tv) do
    print(k, v)
    for i, j in pairs(v) do
      print(i, j)
      for d, e in pairs(j) do
        print(d, e)
      end
    end
  end
  print("--------------------")
end
--]]


-- map:create_torch_surfaces(t_torches)
--[[
for k, v in pairs(t_torches) do
  print("K: ", k, "V: ", v)
  for i, j in pairs(v) do
    print(i, j)
  end
end
--]]

--local camera = map:get_camera()


local function custom_walk(npc)

  -- Speed
  local speed = npc:get_property("speed") or 16

  -- Positions
  local positions = npc:get_property("positions")
  positions = string.gsub(positions, "%s+", "") -- Remove spaces
  -- Create a table from it
  local tbl_positions = {}
  local key, count = 0, 0
  local x, y, layer
  for i in string.gmatch(positions, '([^,}]+)') do
    if string.sub(i, 1, 1) == "{" then
      count = 1
      key = key + 1
      tbl_positions[key] = {}
      tbl_positions[key].x = string.sub(i, 2, #i)
      --print(tbl_positions[key].x)
    else
      count = count + 1
      if count == 2 then
        tbl_positions[key].y = i
        --print(tbl_positions[key].y)
      elseif count == 3 then
        tbl_positions[key].layer = i
      end
    end
  end
  local random = math.random(1, #tbl_positions)
  local x, y, layer = tbl_positions[random].x, tbl_positions[random].y, tbl_positions[random].layer or 0
  npc:set_position(x, y, layer)

  -- Create the movement
  local sprite = npc:get_sprite()
  sprite:set_animation("walking")
  --local m = sol.movement.create("random_path")
  --local m = sol.movement.create("path_finding")
  --m:set_target(entity)
  --m:set_speed(speed)
  --m:start(npc)

end



-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()

  local hero = map:get_hero()
  local hero_x, hero_y, _ = hero:get_position()
  grid_id = map:get_grid_id(hero_x, hero_y)
  print("GRID_ID: ", grid_id)
  

  tiles = sol.surface.create("entities/tiles.png")
  tiles:set_blend_mode("multiply")

  -- You can initialize the movement and sprites of various
  -- map entities here.
  --print(self:get_type())
  map:generate_prop_id()

  --[[for entity in map:get_entities_by_type("enemy") do
    print("----- ID:", entity:get_property("id"))
  end--]]


  custom_walk(old_man)

  function collapse_sensor:on_activated()

    print("collapse_sensor")
    collapse_sensor:remove()
    local index = 1
    hero:save_solid_ground()
    sol.timer.start(300, function()
      local tile = map:get_entity("collapsible_floor_" .. index)
      if tile == nil then
        return false
      end
      tile:set_enabled(false)
      sol.audio.play_sound("misc/dungeon_shake")
      index = index + 1
      return true
    end)

  end


  function boss_sensor:on_activated()

    require("scripts/hud/b_hearts")
    game:set_b_hearts_hud_enabled(true)
    boss_sensor:remove()
    --game:start_dialog("Hey")
  end


 function test_button:on_activated()

    print("test_button")
    test_sensor:remove()
    --hero:save_solid_ground()
    local tile = map:get_entity("test_floor_1")
    tile:set_enabled(false)
    sol.audio.play_sound("misc/dungeon_shake")

  end


end)


function map:on_draw(dst_surface) 

  -- TEST  lighted tiles
  --[[
  for k, v in pairs(t_torches) do
      local surface = t_torches[k].surface
      local x = map_width - t_torches[k].x
      local y = map_height - t_torches[k].y
      print(surface, x, y)
      surface:draw(dst_surface, x, y) 
      surface:fill_color({255, 255, 255, 255})
  end
  --]]
  --local x = t_torches[1].x
  --local y = t_torches[1].y
  --t_torches[1].surface:draw(dst_surface, 128, 0)


  --[[
  local x_camera, y_camera = camera:get_position()
  local x = 0
  local y = 0
  while y < 160 do
    while x < 240 do
      local distance = hero:get_distance(x_camera + x, y_camera + y)
      if distance >= 48 then
        tiles:draw_region(0, 0, 1, 1, dst_surface, x, y)
      elseif distance >= 40 and distance < 48 then
        tiles:draw_region(8, 0, 1, 1, dst_surface, x, y)
      elseif distance >= 32 and distance < 40 then
        tiles:draw_region(16, 0, 1, 1, dst_surface, x, y)
      elseif distance >= 24 and distance < 32 then
        tiles:draw_region(24, 0, 1, 1, dst_surface, x, y)
      end
      x = x + 1
    end
    x = 0
    y = y + 1
  end
  --]]
  map:draw_light_effect(dst_surface, t_torches[grid_id].torches)


  ---------------------------
  -- TEST DU SCRIPT util.lua
  ---------------------------
  --[[
  local util = require"scripts/util"
  local LINE_COLOR = {143, 192, 112}

  --calculate series of rectangles needed to draw line
  local path = util.make_path(
      {x=48, y=40}, --starting coordinates
      {x=100, y=128} --ending coordinates
  )

  --draw the line on surface
  for y,row in pairs(path) do
    local x = row.start
    local width = row.stop - x + 1
    --surface:fill_color(LINE_COLOR, x, y, width, 20)
    --dst_surface:fill_color(LINE_COLOR, x, y, width, 20)
  end
  --]]
  ---------------------------




end



-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.


function map:on_opening_transition_finished()

  -- Test sprites of NPCs with the hero.
  --[[
  for npc in self:get_entities_by_type("npc") do
    function npc:on_interaction()
      local sprite_id = npc:get_sprite():get_animation_set()
      hero:set_tunic_sprite_id(sprite_id)
    end
  end
  --]]

end
