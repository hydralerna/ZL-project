-- Source: Script "ball.lua" ("Zelda - A Link To The Dream")
----------------------------------
--
-- A carriable entity that can be thrown and bounce like a ball.
--
----------------------------------

local megabomb = ...
local carriable_behavior = require("entities/library/carriable")
carriable_behavior.apply(megabomb, {bounce_sound = "shield", respawn_delay = 2000})

local map = megabomb:get_map()

-- Function to make the carriable not traversable by the hero and vice versa. 
-- Delay this moment if the hero would get stuck.
local function set_hero_not_traversable_safely(entity)

  entity:set_traversable_by("hero", true)
  entity:set_can_traverse("hero", true)
  if not entity:overlaps(map:get_hero()) then
    entity:set_traversable_by("hero", false)
    entity:set_can_traverse("hero", false)
    return
  end
  sol.timer.start(entity, 10, function() -- Retry later.
    set_hero_not_traversable_safely(entity)
  end)
end

-- Make the hero traversable on thrown to not get stuck.
megabomb:register_event("on_thrown", function(megabomb, direction)

  set_hero_not_traversable_safely(megabomb)
end)

-- Setup traversable rules for the megabomb.
megabomb:register_event("on_created", function(megabomb)

  -- Traversable rules.
  megabomb:set_traversable_by(false)

  -- Set the hero not traversable as soon as possible, to avoid being stuck if the carriable is (re)created on the hero.
  set_hero_not_traversable_safely(megabomb)
end)

megabomb:register_event("on_finished", function(megabomb)
  print("GAME OVER")
end)