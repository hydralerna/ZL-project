-- Lua script of enemy e_fc_gelatinous_cube

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

local enemy = ...
local init_enemy = require("enemies/library/generic_waiting_for_hero")
init_enemy(enemy)
enemy:set_properties({
   sprite = "enemies/bosses/e_fc_gelatinous_cube",
   traversable = false,
   invincible = false,
   life = 12,
   damage = 1 ,
   normal_speed = 8,
   faster_speed = 48,
   detection_distance = 32,
   max_distance = 16,
   straight = true,
   grid = true,
   hurt_style = "boss",
   push_hero_on_sword = true,
   pushed_when_hurt = false,
   attacking_collision_mode = "containing",
   normal_animation = "walking"
 })

function enemy:on_dying()

  local timer = sol.timer.start(1500, function()
    local sprite = enemy:get_sprite()
    sprite:set_animation("dying")
  end)
end

function enemy:on_dead()

  local game = enemy:get_game()
  local map = game:get_map()
  local x, y, layer = enemy:get_position()
  game:add_exp(30)
  map:create_chest({
    layer = layer,
    x = x - 8,
    y = y - 32,
    sprite = "chests/chest03",
    treasure_name = "heart_container",
    treasure_variant = 1,
    treasure_savegame_variable = "chest_gelatinous_cube",
  })
  map:create_pickable({
    layer = layer,
    x = x + 4,
    y = y - 24,
    sprite = "items/rupee",
    treasure_name = "rupee",
    treasure_variant = 3,
  })
  map:create_pickable({
    layer = layer,
    x = x - 20,
    y = y - 40,
    sprite = "items/coin",
    treasure_name = "coin",
    treasure_variant = 1,
  })
  map:create_pickable({
    layer = layer,
    x = x - 16,
    y = y - 7,
    sprite = "items/coin",
    treasure_name = "coin",
    treasure_variant = 1,
  })
  map:create_enemy({
    name = "skeleton02",
    breed = "e_fc_skeleton_02",
    layer = layer,
    x = x - 8,
    y = y,
    direction = 3,
    treasure_name = "coin",
    treasure_variant = 2,
  })
  map:create_enemy({
    name = "skeleton02",
    breed = "e_fc_skeleton_02",
    layer = layer,
    x = x + 16,
    y = y,
    direction = 0,
    treasure_name = "rupee",
    treasure_variant = 1,
  })
  map:create_enemy({
    name = "skeleton02",
    breed = "e_fc_skeleton_02",
    layer = layer,
    x = x + 8,
    y = y - 32,
    direction = 0,
    treasure_name = "rupee",
    treasure_variant = 2,
  })
end


