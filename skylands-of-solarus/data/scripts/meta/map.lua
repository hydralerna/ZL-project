-- Initialize Map behavior specific to this quest.

-- Variables
local map_meta = sol.main.get_metatable("map")
local grid_id

-- Include scripts
require ("scripts/multi_events")

-- Set the camera size to avoid problems with the hud
map_meta:register_event("on_started", function(map)

  local camera = map:get_camera()
  camera:set_position_on_screen(72, 40)
  camera:set_size(240, 160)

  local camera = map:get_camera()
  local camera_x, camera_y, _ = camera:get_position()
  grid_id = map:get_grid_id(camera_x, camera_y)
  print("grid_id (map:on_started)", grid_id)
end)


-- TEST
function map_meta:get_grid_id(xp, yp)

  -- Create an array from alphabet
  local str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local alphabet = {}
  for i = 1, #str do alphabet[i] = str:sub(i, i) end
  -- Get grid from a point in the grid
  local col = alphabet[math.floor(xp / 240) + 1]
  local row = tostring((math.floor(yp / 160) + 1))
  return col .. row -- Example: E3
end
  




function map_meta:create_table_lights()

	-- Function to check if a table contains a specific value in the key named "pattern" of each sub-table
	local function contains_pattern(val)
    local ref_pattern_ids = {1, 2, 3, 4}
    --local ref_pattern_ids = {1}
		for _, v in pairs(ref_pattern_ids) do
			if val == v then
				return true
			end
		end
		return false
	end
	-- Parses the specified map data files and returns an array of information on their special tiles.
	-- Each element of the array is a table with the following fields:
	-- x, y, width, height.
	local tiles = {}
	local map_x, map_y, map_w, map_h
  -- Function to init a table and a sub-table in table named "tiles", e.g. table_init("E3", "torches")
  -- ("gid" means "Grid ID" for map divided into several parts)
  -- ("elt" means "element" which is for examples "torches" or "braseros")
  local function table_init(t_gid, t_elt)
   if tiles[t_gid] == nil then    
     tiles[t_gid] = {}
   end
   if tiles[t_gid][t_elt] == nil then
     tiles[t_gid][t_elt] = {}
   end
  end
	-- Here is the magic: set up a special environment to load map data files.
	local environment = {
		properties = function(map_properties)
		-- Remember the map location and size
		-- to be used for subsequent tiles.
		map_x = map_properties.x
		map_y = map_properties.y
		map_w = map_properties.width
		map_h = map_properties.height
		end,
		tile = function(tile_properties)
			local pattern = tonumber(tile_properties.pattern)
      local tileset = tile_properties.tileset
      if type(tileset) == "string" then
  			-- Get the info about this tile and store it into the table.
  			if contains_pattern(pattern) and tileset:match("torch") then
          local x_offset = map_x + tile_properties.x + (tile_properties.width / 2)
          local y_offset = map_y + tile_properties.y + (tile_properties.height / 2)
          local grid_id = self:get_grid_id(x_offset, y_offset)
          table_init(grid_id, "torches")
  				tiles[grid_id]["torches"][#tiles[grid_id]["torches"] + 1] = {
  				x = x_offset,
  				y = y_offset,
          cx = math.floor(x_offset % 240),
          cy = math.floor(y_offset % 160),
  				radius = math.max(tile_properties.width, tile_properties.height) * 5,
  				}
  			end
      end
		end,
	}
	-- Make any other function a no-op (tile(), enemy(), block(), etc.).
	setmetatable(environment, {
		__index = function()
		return function() end
    end
	})
	-- Load the map data file as Lua.
	local chunk = sol.main.load_file("maps/" .. self:get_id() .. ".dat")
	-- Apply our special environment (with functions properties()).
	setfenv(chunk, environment)
	-- Run it.
	chunk()
	return tiles
end

-- Check if a given point is inside a rectangle
--[[ NOT USED
function in_rectangle(x1, y1, x2, y2, xp, yp)

     return xp >= x1 and xp < x2 and yp >= y1 and yp < y2
end
--]]

-- Check if a given point is inside a circle
function in_circle(x0, y0, radius, xp, yp)

      return ((x0 - xp)^2 + (y0 - yp)^2)  <= radius^2
end

-- TODO Trouver comment l'on peut changer le Grid ID en fonction du morceau de cartes
-- TODO Trouver un nom plus parlant pour les variables liés à Grid ID
-- TODO Faire en sorte qu'on utilise un dégradé aussi pour les torches 
function get_distance_from_center(x0, y0, xp, yp) 

  return math.floor(math.sqrt((xp - x0)^2 + (yp - y0)^2))
end
-- TODO Lumos par rond autour du héros
-- TODO Trouver un moyen de réduire le nom d'occurence (Plus c'est loin d'une source de lumière, plus prendre de gros pixels) 
-- TODO A voir si l'on peut jouer avec la luminosité en fonction du nombre de points de vie du héros
-- TODO Adapter pour les braseros et autres sources de lumières
-- TODO Trouver un moyen pour que les entité de type fau par exemple dégage de la lumière
-- TODO Jouer avec la profondeur des lumières

-- Draw a light effect from a table created by the function named "create_table_lights"
function map_meta:draw_light_effect(dst_surface, tbl)

  local hero = self:get_hero()
  --local game = self:get_game()
  --local life = game:get_life()
  --local max_life = game:get_max_life()
  local camera = self:get_camera()
  local x_camera, y_camera = camera:get_position()
  --print(x_camera, y_camera)
  local x = 0
  local y = 0
  local px = 1
  while y < 160 do
    while x < 240 do
      local lumos = false
      for k, t in pairs(tbl) do
        lumos = in_circle(t.cx, t.cy, t.radius, x, y)
        if lumos then
          break
        end
      end
      if not lumos then
        local distance = hero:get_distance(x_camera + x, y_camera + y)
        if distance >= 104 then
          tiles:draw_region(0, 0, px, px, dst_surface, x, y)
        elseif distance >= 80 and distance < 104 then
          tiles:draw_region(8, 0, px, px, dst_surface, x, y)
        elseif distance >= 64 and distance < 80 then
          tiles:draw_region(16, 0, px, px, dst_surface, x, y)
        elseif distance >= 56 and distance < 64 then
          tiles:draw_region(24, 0, px, px, dst_surface, x, y)
        elseif distance >= 0 and distance < 56 then
          tiles:draw_region(32, 0, px, px, dst_surface, x, y)
        end
      end
      x = x + px
    end
    x = 0
    y = y + px
  end

end




-- Generate an ID for an entity
function map_meta:generate_prop_id(entity, force)

  -- Set variables.
  local enemies = entity == nil and true or false
  local type = enemies and "enemy" or entity:get_type()
  if (force == nil) then force = false end
  -- Function to check if a value exists in an array.
  local function has_value(tbl, val)
  for _, v in ipairs(tbl) do
    if v == val then
      return true
    end
  end
  return false
  end
  -- Function to convert an integer into a string of 4 characters.
  local function format_id(int)
    local str = tostring(int)
    local str = string.rep("0", 4 - #str) .. str -- e.g. 0032 (We add 00 before 32). 
    return str
  end
  -- Set a property named "id" for ALL entities defined by "type" in the current map.
  if (enemies) then
    local id = 1
    for entity in self:get_entities_by_type(type) do
      entity:set_property("id", format_id(id))
      id = id + 1
    end
  -- Otherwise, create an array containing all the IDs found for the entities (defined by "type") in the current map ...
  else
    if ((entity:get_property("id") == nil) or force) then
      local ids = {}
      for ent in self:get_entities_by_type(type) do
        local id = ent:get_property("id")
        if (id ~= nil) then
          ids[#ids + 1] = id
        end
      end
    -- ... and generate a random number from 1 to 9999 and return it as a string.
      repeat
        local id = math.random(1, 9999)
        entity:set_property("id", format_id(id))
      until(has_value(ids, id) == false)
      end
    end
end