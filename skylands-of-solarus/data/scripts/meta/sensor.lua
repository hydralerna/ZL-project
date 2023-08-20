-- Initialize Sensor behavior specific to this quest.

-- Variables
local sensor_meta = sol.main.get_metatable("sensor")

-- Include scripts
require ("scripts/multi_events")

--[[
function sensor_meta:on_activated(direction4)

  if self:get_property("boss") ~= nil then
    local map = self:get_map()
    local camera = map:get_camera()
    local x, y, layer = camera:get_position()
    local width, height = camera:get_size()
    for entity in map:get_entities_in_rectangle(x, y, width, height) do
      if entity:get_type() == "enemy" and entity:is_enabled() then
        if entity:get_property("boss") ~= nil then
          self:set_property("boss", nil)
          entity:get_game():start_dialog("boss." .. entity:get_name())
        end
      end
    end
  end

end
--]]

function sensor_meta:on_activated(direction4)

  -- WIP
  --[[
  local function check_name(prefix, name)
    local has_prefix = nil
    local has_name = nil
    if name ~= nil then
      local prefix = name:match("^" .. prefix)
      local shortname = name:match("(.-)_%d+$")
      if shortname then
        name = shortname
      end
    end
    return has_prefix, prefix, has_name, name
  end
  local has_prefix, prefix, has_name, name = check_name("boss_", self:get_name())
  print("has_prefix: ", has_prefix, ", prefix: ", prefix, ", has_name: ", has_name, ", name: ", name)
  --]]
  local name = self:get_name()
  local str = "boss_"
  if name ~= nil then
    local shortname = name:match("(.-)_%d+$")
    if shortname then
      name = shortname
    end
    local prefix = name:match("^" .. str)
    if prefix == str then
      local map = self:get_map()
      local camera = map:get_camera()
      local x, y, _ = camera:get_position()
      local width, height = camera:get_size()
      for entity in map:get_entities_in_rectangle(x, y, width, height) do
        local name = entity:get_name()
        if name ~= nil then
          local shortname = name:match("(.-)_%d+$")
          if shortname then
            name = shortname
          end
        end
        if entity:get_type() == "enemy" and entity:is_enabled() and name ~= nil and entity:get_layer() ==  map:get_hero():get_layer() then
          local prefix = name:match("^" .. str)
          if prefix == str then
            entity:get_game():start_dialog(str:gsub("_", ".") .. name:match(str .. "(.*)"))
            self:set_enabled(false)
          end
        end
      end
    end
  end

end

return true