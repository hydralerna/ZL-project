    -- 3 fireballs shot by enemies like Zora and that go toward the hero.
    -- They can be hit with the sword, this changes their direction.
    local enemy = ...
     
    local sprites = {}
    local delay = 100
    local hit = false
    local damage = 4
    local life = 1


    function enemy:on_created()
     
      enemy:set_life(life)
      enemy:set_damage(damage)
      enemy:set_minimum_shield_needed(2)  -- Shield 2 can block fireballs.
      enemy:set_size(8, 8)
      enemy:set_origin(4, 4)
      enemy:set_can_hurt_hero_running(true)
      enemy:set_pushed_back_when_hurt(false)
      enemy:set_obstacle_behavior("flying")
      enemy:set_invincible()
      enemy:set_attack_consequence("sword", "custom")
     
      for i = 0, 2 do 
        sprites[#sprites + 1] = enemy:create_sprite("enemies/" .. enemy:get_breed())
      end
    end


    local function go(angle, speed)
     
      local movement = sol.movement.create("straight")
      movement:set_speed(speed)
      movement:set_angle(angle)
      movement:set_smooth(false)
     
      function movement:on_obstacle_reached()
       
        enemy:hurt(life)
      end
     
      function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
 
        local name = enemy:get_name()
        -- print("NAME: ", name)
        local other_id = other_enemy:get_id()
        -- print(name, owner_id, projectile, other_id)
        -- print(name, other_enemy:get_breed():match("(.+)_"))
        -- print(name, other_enemy:get_breed())
        if name ~= nil and other_id ~= nil then
          local owner_id, projectile = name:match("(.-)_(.+)")
          -- print("OWNER ID: ",  owner_id, "PROJ: ", projectile)
          if (owner_id ~= other_id) or hit then
            other_enemy:hurt(damage)
            enemy:remove()
          end
        end
      end

      -- Compute the coordinate offset of follower sprites.

      sol.timer.start(enemy, delay, function()
        local x = -math.cos(angle) * 5
        local y = math.sin(angle) * 5
        sprites[2]:set_xy(x, y)
        sprites[3]:set_xy(2 * x, 2 * y)
        sprites[2]:set_animation("following_1")
        sprites[3]:set_animation("following_2")
      end)
      movement:start(enemy)
    end


    function enemy:on_restarted()
     
      local hero = enemy:get_map():get_hero()
      local angle = enemy:get_angle(hero:get_center_position())
      go(angle, 100)
    end


    -- Destroy the fireball when the hero is touched.
    function enemy:on_attacking_hero(hero, enemy_sprite)
     
      hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
      enemy:remove()
    end


    -- Change the direction of the movement when hit with the sword.
    function enemy:on_custom_attack_received(attack, sprite)
     
      if attack == "sword" and sprite == sprites[1] then
        local hero = enemy:get_map():get_hero()
        local movement = enemy:get_movement()
        if movement == nil then
          return
        end
     
        local old_angle = movement:get_angle()
        local angle
        local hero_direction = hero:get_direction()
        if hero_direction == 0 or hero_direction == 2 then
          angle = math.pi - old_angle
        else
          angle = 2 * math.pi - old_angle
        end
        delay = 0
        go(angle, 200)
        sol.audio.play_sound("enemy_hurt")
        hit = true
        -- The trailing fireballs are now on the hero: don't attack temporarily
        enemy:set_can_attack(false)
        sol.timer.start(enemy, 500, function()
          enemy:set_can_attack(true)
        end)
      end
    end


    function enemy:on_dying()

      local sprite = sprites[1]
      function sprite:on_animation_finished(animation)
        enemy:remove()
      end
    end