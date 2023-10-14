--[[
Lighting system by Max Mraz. Licensed MIT
This is meant to be used with the script at scripts/fx/lighting/lighting manager. Both should be required when the program or game is started
This script automatically creates lighting effects around certain entities:

### Static Light Sources:
These light sources must exist at the map's creation, and cannot move or be removed
- Any entity with a name starting with "^sprite_light_source" will have its sprite applied as a light source.
- And entity with a name starting with "^lighting_effect" will be checked for keywords in its name:
  - "candle" : will produce a small circle of light
  - "torch" : will produce a medium circle of light
  - "entrance" : will produce a special effect

### Dynamic Light Sources:
The map will check for entities that meet a certain criteria, and if they're close enough to the camera, will apply a light source sprite to them
See scripts/fx/lighting/dynamic_light_source_sprite_manager for details
the function `manager:create_light_source()` from that script takes an entity, and returns an table with the values
- `entity` the entity passed to the function
- `sprite` a sprite object to be drawn at the entity's coordinates
Note: the function can use `lighting_manager:get_effect_sprites()` to just redraw a few preset sprites, rather than creating new sprites.
--]]

local lighting_manager = require"scripts/fx/lighting/lighting_manager"
local dynamic_light_source_sprite_manager = require"scripts/fx/lighting/dynamic_light_source_sprite_manager"
local map_meta = sol.main.get_metatable"map"

function map_meta:set_darkness_level(level)
  local map = self
  if not sol.menu.is_started(lighting_manager) then
    sol.menu.start(self, lighting_manager)
  end
  lighting_manager:set_darkness_level(level)

  --Add static light sources
  map.static_light_sources = {}
  local effect_sprites = lighting_manager:get_effect_sprites()

  local function add_static_light_source(entity)
    local x, y, z = entity:get_position()
    local source = {
      sprite = entity:get_sprite(),
      x = x,
      y = y,
    }
    table.insert(map.static_light_sources, source)
  end

  --Iterate through all map entities to find static light sources
  for entity in map:get_entities() do
    local name = entity:get_name()
    print("NAME: ", name)
    if not name then name = "" end

    if name:match("^sprite_light_source") then
      add_static_light_source(entity)

    elseif name:match("%^lighting_effect") then
      local x, y, z = entity:get_position()
      local width, height = entity:get_size()
      local source = {x=x, y=y}
      if string.match(name, "torch") then
        if string.match(name, "right") then
          source.sprite = effect_sprites.torch0
          source.sprite:set_direction(0)
          source.x = x + 32
          source.y = y + (height / 2)
        elseif string.match(name, "up") then
          source.sprite = effect_sprites.torch1
          source.sprite:set_direction(1)
          source.x = x + (width / 2)
          source.y = y + (height - 32)
        elseif string.match(name, "left") then
          source.sprite = effect_sprites.torch2
          source.sprite:set_direction(2)
          source.x = x + (width - 32)
          source.y = y + (height / 2)
        elseif string.match(name, "down") then
          source.sprite = effect_sprites.torch3
          source.sprite:set_direction(3)
          source.x = x + (width / 2)
          source.y = y + 32
        else
          source.sprite = effect_sprites.torch4
          source.sprite:set_direction(4)
          source.x = x + (width / 2)
          source.y = y + (height / 2)
        end
      elseif string.match(name, "candle") then
        source.sprite = effect_sprites.candle
      elseif string.match(name, "entrance") then
        source.sprite = effect_sprites.entrance
      end
      table.insert(map.static_light_sources, source)

    elseif entity:get_property("lighting_effect_type") or entity.lighting_effect_type then
      local effect_type = entity:get_property"lighting_effect_type" or entity.lighting_effect_type
      --If entity sprite light source
      if effect_type == "sprite" then
        add_static_light_source(entity)
      --If preset light source
      else
        local x, y, z = entity:get_position()
        local source = {x=x, y=y}
        if effect_type == "torch" then
          source.sprite = effect_sprites.torch
        elseif effect_type == "candle" then
          source.sprite = effect_sprites.candle
        end
        table.insert(map.static_light_sources, source)
      end
    end
  end

  --Check certain entities by name for static light sources
  --[[
  for entity in map:get_entities("^sprite_light_source") do
    add_static_light_source(entity)
  end

  for entity in map:get_entities("^lighting_effect") do
    local name = entity:get_name()
    local x, y, z = entity:get_position()
    local source = {x=x, y=y}
    if string.match(name, "torch") then
      source.sprite = effect_sprites.torch
    elseif string.match(name, "candle") then
      source.sprite = effect_sprites.candle
    elseif string.match(name, "entrance") then
      source.sprite = effect_sprites.entrance
    end
    table.insert(map.static_light_sources, source)
  end
  --]]

  --check for dynamic light sources regularly
  local camera = map:get_camera()
  local width, height = camera:get_size()
  local hero = map:get_hero()
  sol.timer.start(map, 20, function()
    map.dynamic_light_sources = {}
    if hero:get_state() == "lying" or hero:get_state() == "carrying" then
        local carried_object = hero:get_carried_object()
        local animation_set = carried_object:get_sprite():get_animation_set()
        if animation_set == "entities/bomb" then
          local source = dynamic_light_source_sprite_manager:create_light_source(carried_object)
          if source.sprite then table.insert(map.dynamic_light_sources, source) end
        end
    end
    local camx, camy = camera:get_center_position()
    for entity in map:get_entities_in_rectangle(camx - width, camy - height, width * 3, height * 3) do
      if not entity:is_enabled() then return end
      if not entity:is_visible() then return end
      if not entity:exists() then return end
      local source = dynamic_light_source_sprite_manager:create_light_source(entity)
      if source.sprite then table.insert(map.dynamic_light_sources, source) end
    end
    return true
  end)

end



function map_meta:get_darkness_level()
  return lighting_manager:get_darkness_level()
end