-- Lua script of enemy e_fc_skeleton_01.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

local enemy = ...
local init_enemy = require("enemies/library/generic_waiting_for_hero")
init_enemy(enemy)
enemy:set_properties({
   sprite = "enemies/e_fc_skeleton_01",
   life = 3,
   damage = 1,
   normal_speed = 8,
   faster_speed = 16,
   detection_distance = 48,
   more_distance = 32,
   hurt_style = "normal",
   push_hero_on_sword = false,
   pushed_when_hurt = true,
   movement_create = function()
     local m = sol.movement.create("random_path")
     return m
   end
 })