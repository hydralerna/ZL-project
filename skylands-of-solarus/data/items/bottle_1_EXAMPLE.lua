--[[
local item = ...

function item:on_created()
  self:set_assignable(true)
  self:set_savegame_variable("possession_bottle_1")
end

local bottle_script = require("items/library/bottle.lua")
bottle_script(item)
--]]