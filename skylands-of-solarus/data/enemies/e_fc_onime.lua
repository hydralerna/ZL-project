-- Lua script of enemy e_fc_onime.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
--local movement
local going_hero = false
local awaken = false
local angle
local tempus


function crab(d8)

   local a
   if d8 == 0 then
      a = 0
   elseif d8 == 1 then
      a = 0
   elseif d8 == 2 then
      a = math.pi / 2
   elseif d8 == 3 then
      a = math.pi
   elseif d8 == 4 then
      a = math.pi
   elseif d8 == 5 then
      a = math.pi
   elseif d8 == 6 then
      a = 3 * math.pi / 2
   else
      a = 0
   end
  return a
end

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  self:set_life(3)
  self:set_damage(1)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  sprite:set_animation("sleeping")
  sprite:set_direction(3)
  -- print("SLEEPING")
end


function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  if going_hero then
    sprite:set_animation("walking")
  else
    sprite:set_animation("stopped")
  end
  sprite:set_direction(direction4)
  --print("MOVEMENT")
end


function enemy:on_restarted()

  local sprite = self:get_sprite()
  print("RESTART")
  if going_hero then
    sprite:set_animation("walking")
  else
    sprite:set_animation("stopped")
  --else
   -- sprite:set_animation("sleeping")
  end
  self:check_hero()

  --movement = sol.movement.create("target")
  --movement:set_target(hero)
  --movement:set_speed(0)
  --movement:start(enemy)

end


function enemy:check_hero()

  local hero = self:get_map():get_entity("hero")
  --local near_hero = self:get_distance(hero) < 64 and self:is_in_same_region(hero)
  local near_hero = self:is_in_same_region(hero)
  local direction8 = self:get_direction8_to(hero)
  tempus = 360
  angle = crab(direction8)
  print(direction8, angle)
  if direction8 ~= 2 and direction8 ~= 6 then
      --print("go_hero")
      self:go_hero()
  else
  --if awaken then
    --if near_hero and not going_hero then
        --print("asleep")
        tempus = 3600
        self:asleep()
    --elseif not near_hero and going_hero then
     --   self:asleep()
    --end
  --elseif not awaken and near_hero then
    -- self:wake_up()
   -- self:go_hero()
  --end
  end
  print(tempus)
  sol.timer.stop_all(self)
  sol.timer.start(self, tempus, function() self:check_hero() end)
end


function enemy:asleep()

  going_hero = false
  awaken = false
  local m = sol.movement.create("target")
  m:set_speed(0)
  m:set_ignore_obstacles(false)
  m:start(self)
  print("zzzzzzzzzz")
end


function enemy:go_hero()

  going_hero = true
  awaken = false
  local m = sol.movement.create("straight")
  m:set_speed(20)
  m:set_angle(angle)
  m:set_max_distance(32)
  m:set_ignore_obstacles(false)
  m:start(self)
  -- print("GO")
end

