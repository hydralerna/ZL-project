    -- An enemy who shoots fireballs.
     
    local enemy = ...
    local sprite
    local map = enemy:get_map()
     
    function enemy:on_created()
     
      enemy:set_life(5)
      enemy:set_damage(2)
      -- enemy:set_obstacle_behavior("swimming")
      enemy:set_pushed_back_when_hurt(false)
      enemy:set_size(16, 16)
      enemy:set_origin(8, 13)
     
      sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
      function sprite:on_animation_finished(animation)
        if animation == "shooting" then
          sprite:set_animation("walking")
        end
      end
    end
    


    function enemy:on_restarted()
     
      local sprite = enemy:get_sprite()
      local hero = enemy:get_map():get_hero()
      sprite:set_direction(enemy:get_direction4_to(hero))
      sol.timer.start(enemy, 1000, function()
        if enemy:get_distance(hero) < 96 then
          sol.audio.play_sound("enemies/genie_fireball")
          sprite:set_animation("shooting")
          local direction = sprite:get_direction()
          local x, y, layer = enemy:get_position()
          local prop = {x = x, y = y, layer = layer, direction = direction, breed = "projectiles/e_fc_fireball_small_01",}
          map:create_enemy(prop)
        end
        return true  -- Repeat the timer.
      end)
    end
     