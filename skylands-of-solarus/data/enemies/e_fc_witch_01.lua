-- Lua script of enemy e_fc_witch_01.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

  local enemy = ...
  local sprite
  local map = enemy:get_map()
  local timer

  local going_random = true


  function enemy:on_created()

    enemy:set_life(8)
    enemy:set_damage(0)
    enemy:set_pushed_back_when_hurt(true)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 13)
    sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
    function sprite:on_animation_finished(animation)
      if animation == "shooting" then
        sprite:set_animation("walking")
        going_random = false
      end
    end
  end


  function enemy:on_restarted()

    enemy:go_random()
    enemy:check_hero()
  end


  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = enemy:get_sprite()
    sprite:set_direction(direction4)
  end


  function enemy:check_hero()

    local hero = map:get_entity("hero")
    local _, _, layer = enemy:get_position()
    local _, _, hero_layer = hero:get_position()
    local distance = enemy:get_distance(hero)
    local near_hero = layer == hero_layer and distance < 96
    if near_hero and going_random then
      enemy:attack()
    elseif not going_random then
      enemy:go_random()
    end
    if timer == nil or timer:get_remaining_time() == 0 then
      sol.timer.stop_all(enemy)
      sol.timer.start(enemy, 100, function() enemy:check_hero() end)
    end
  end


  function enemy:go_random()

    local movement = sol.movement.create("random_path")
    movement:set_speed(16)
    movement:start(enemy)
    going_random = true
  end


  function enemy:attack()

    enemy:stop_movement()
    sol.audio.play_sound("enemies/genie_fireball")
    sprite:set_animation("shooting")
    timer = sol.timer.start(enemy, 13 * sprite:get_frame_delay(), function()
        local name = enemy:get_id()  .. "_" .. enemy:get_breed()
        local direction = sprite:get_direction()
        local x, y, layer = enemy:get_position()
        if direction % 2 == 0 then
          x = direction == 0 and x + 8 or x - 8
        else
          y = direction == 1 and y - 8 or y + 8
        end
        local prop = {name = name, x = x, y = y, layer = layer, direction = direction, breed = "projectiles/e_fc_fireball_small_01",}
        local remaining_time = timer:get_remaining_time()
        map:create_enemy(prop)
        sol.timer.start(enemy, 2 * sprite:get_frame_delay(), function()
          enemy:check_hero()
        end)
    end)
  end
