local game_metatable = sol.main.get_metatable("game")
local serpent = require"scripts/utility/serpent"

function game_metatable:set_table_value(key, table)
  local t = serpent.dump(table)
  --t = string.format("%q", t)
  --t = t:sub(1, -2)
  --t = t:sub(2)
  t = string.gsub(t, '"', '\\"')
  self:set_value(key, t)
end

function game_metatable:get_table_value(key)
  local value = self:get_value(key)
  if value == nil then return nil end
  value = value:gsub('\\"', '"')
  local ok, t = serpent.load(value)
  if ok then return t end
end
