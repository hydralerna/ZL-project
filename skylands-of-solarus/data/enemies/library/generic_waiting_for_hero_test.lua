-- Generic script for an enemy that is in a sleep state,
-- and goes towards the the hero when he sees him,
-- and then goes randomly if it loses sight.
-- The enemy has only two new sprites animation: an asleep one,
-- and an awaking transition.
-- a different walking one can be set in the properties, though.

-- Example of use from an enemy script:

-- local init_enemy = require("enemies/library/generic_waiting_for_hero")
-- init_enemy(enemy)
-- enemy:set_properties({
--   sprite = "enemies/globul",
--   traversable = true,
--   invincible = false,
--   life = 4,
--   damage = 2,
--   normal_speed = 8,
--   faster_speed = 16,
--   detection_distance = 48,
--   max_distance = 80,
--   straight = false,
--   grid = true,
--   autosize = false,
--   hurt_style = "normal",
--   push_hero_on_sword = false,
--   pushed_when_hurt = true,
--   asleep_animation = "asleep",
--   awaking_animation = "awaking",
--   normal_animation = "walking",
--   obstacle_behavior = "flying",
--   awakening_sound  = "stone"
-- })

-- The parameter of set_properties() is a table.
-- Its values are all optional except the sprites.
return function(enemy)

  local properties = {}

  function enemy:set_properties(prop)

    properties = prop
    -- Set default values.

    if properties.traversable == nil then
      properties.traversable = true
    end
    if properties.invincible == nil then
      properties.invincible = false
    end
    if properties.life == nil then
      properties.life = 2
    end
    if properties.damage == nil then
      properties.damage = 2
    end
    if properties.normal_speed == nil then
      properties.normal_speed = 8
    end
    if properties.faster_speed == nil then
      properties.faster_speed = 16
    end
    if properties.detection_distance == nil then
      properties.detection_distance = 48
    end
    if properties.max_distance == nil then
      properties.max_distance = 80
    end 
    if properties.state == nil then
      properties.state = "going_random"  -- "stopped", "going_hero", "going_leader", "going_random", "going_straight", "going_back" or "paused".
    end
    if properties.straight == nil then
      properties.straight = false
    end
    if properties.grid == nil then
      properties.grid = true
    end
    if properties.autosize == nil or properties.autosize == false then
      properties.width = properties.width == nil and 16 or properties.width
      properties.height = properties.height == nil and 16 or properties.height
      properties.x = properties.x == nil and 8 or properties.x
      properties.y = properties.y == nil and 13 or properties.y
    end
    if properties.hurt_style == nil then
      properties.hurt_style = "normal"
    end
    if properties.pushed_when_hurt == nil then
      properties.pushed_when_hurt = true
    end
    if properties.push_hero_on_sword == nil then
      properties.push_hero_on_sword = false
    end
    if properties.attacking_collision_mode == nil then
      properties.attacking_collision_mode = "sprite"
    end
    if properties.asleep_animation == nil then
      properties.asleep_animation = "asleep"
    end
    if properties.attack_animation == nil then
      properties.attack_animation = "attack"
    end
    if properties.awaking_animation == nil then
      properties.awaking_animation = "awaking"
    end
    if properties.normal_animation == nil then
      properties.normal_animation = "walking"
    end
    if properties.obstacle_behavior == nil then
      properties.obstacle_behavior = "normal"
    end
    if properties.stopped_animation == nil then
      properties.stopped_animation = "stopped"
    end
  end

  function enemy:on_created()

    local sprite = self:create_sprite(properties.sprite)
    properties.breed = enemy:get_breed()
    properties.initial_xy = {}
    properties.initial_xy.x, properties.initial_xy.y = self:get_position()
    properties.num_directions = sprite:get_num_directions(properties.normal_animation)
    if properties.autosize then
      local width, height = sprite:get_size(properties.normal_animation, properties.num_directions - 1)
      local x, y = sprite:get_origin(properties.normal_animation, properties.num_directions - 1)
      properties.width = properties.width == nil and width or properties.width
      properties.height = properties.height == nil and height or properties.height
      properties.x = properties.x == nil and x or properties.x
      properties.y = properties.y == nil and y or properties.y
    end
    self:set_size(properties.width, properties.height)
    self:set_origin(properties.x, properties.y)
    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_attacking_collision_mode(properties.attacking_collision_mode)
    if properties.traversable == true then
      self:set_traversable()
    else
      self:set_traversable(false)
    end
    if properties.invincible == true then
      self:set_invincible()
    else
      self:set_invincible(false)
      self:set_default_attack_consequences()
    end
    if not properties.obstacle_behavior == nil then
      self:set_obstacle_behavior(properties.obstacle_behavior)
    end

    function sprite:on_animation_finished(animation)

      -- If the awakening transition is finished, make the enemy go toward the hero.
      if animation == properties.awaking_animation then
        --print("on_animation_finished, ", animation)
        self:set_animation(properties.normal_animation)
        if grid == true then
          self:snap_to_grid()
        end
        if properties.straight == true then
            enemy:go_straight()
        else
          if enemy:get_name() == properties.leader_name then
            enemy:go_hero()
          else
            enemy:go_leader()
          end
        end
      end
    end
    --sprite:set_animation(properties.asleep_animation)
  end

  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    if properties.num_directions == 1 then
      sprite:set_direction(0)
    else
      sprite:set_direction(direction4)
    end
  end

  function enemy:on_obstacle_reached(movement)

    if properties.state == "stopped" then
      self:check_hero()
    elseif properties.state == "going_straight" then
      self:go_back()
    end
  end

  function enemy:on_movement_finished()

    if properties.state == "going_straight" or properties.state == "going_back"  then
      self:go_back()
    end
  end

  function enemy:on_restarted()

print("enemy:on_restarted() properties.state: ", properties.state)
    if properties.state == "asleep" then
      self:asleep()
    elseif properties.state == "going_random" then
      self:go_random()
    else
      if properties.straight == true then
        self:go_back()
      else
        print("TEST NAMES in enemy:on_restarted(): ", self:get_name(), properties.leader_name)
        if self:get_name() == properties.leader_name then
          self:go_hero()
        else
          self:go_leader()
        end
      end
    end
    self:check_hero()
  end

  function enemy:check_hero()

    sol.timer.start(enemy, 250, function()
      local map = self:get_map()
      local hero = map:get_entity("hero")
      local _, _, layer = self:get_position() --TODO x, y?
      local x, y, width, height = self:get_bounding_box() --TODO x, y?
      if self:overlaps(hero, "containing", self:get_sprite(), hero:get_sprite()) then
        if math.random(5) == 1 then
          self:get_game():remove_life(1)
        end
      end
      --local count = 0
      for other_entity in map:get_entities_in_rectangle(x, y, width, height) do
        if other_entity:get_type() == "enemy" and self:overlaps(other_entity, "containing", self:get_sprite(), other_entity:get_sprite()) then
          if other_entity:get_breed() == properties.breed then
          else
              --count = count + 1
              --print("count: ", count, ", life: ", other_entity:get_life())
              local other_entity_prefix = string.sub(other_entity:get_name(), 0, 10)
              if other_entity_prefix == "skeleton01" then
                local sprite = self:get_sprite()
                sprite:set_animation(properties.attack_animation, properties.stopped_animation)
                local x, y, layer = other_entity:get_position()
                local life = other_entity:get_life()
                local direction4 = math.random(0, 3)
                other_entity:remove()
                local other_entity = map:create_enemy({
                    name = "skeleton_02",
                    breed = "e_fc_skeleton_02",
                    layer = layer,
                    x = x,
                    y = y,
                    direction = direction4
                  })
                local other_entity_sprite = other_entity:get_sprite()
                other_entity_sprite:set_animation("walking")
                other_entity_sprite:set_direction(direction4)
                other_entity:set_life(life)
                local other_entity_movement = sol.movement.create("target")
                other_entity_movement:set_target(hero)
                other_entity_movement:set_ignore_obstacles(true)
                other_entity_movement:set_speed(2)
                other_entity_movement:start(other_entity)
              end
              if math.random(50) == 1 then
                if other_entity:get_life() == 1 then
                  other_entity:remove()
                else
                  other_entity:remove_life(1)
                end
              end
          end
        end
      end
      print("NAME", self:get_name(), "LEADER NAME: ", properties.leader_name)
      if properties.leader_name == nil then
        for other_entity in map:get_entities_in_region(hero) do
          if other_entity:get_type() == "enemy" and properties.leader_name == nil then
            local prefix, suffix = other_entity:get_name():match("(.+)_(.+)")
            local oe_prefix, oe_suffix = other_entity:get_name():match("(.+)_(.+)")
            if prefix == oe_prefix then
              properties.leader_name = other_entity:get_name()
              print(other_entity:get_name())
            end
          end
        end
      else
        if not map:has_entity(properties.leader_name) then
          print("had_entity - LEADER NAME: ", properties.leader_name)
          properties.leader_name = nil
        end
      end

      local hero_x, hero_y, hero_layer = hero:get_position()
      local dx, dy = hero_x - x, hero_y - y
      local distance = self:get_distance(hero)
      local near_hero = layer == hero_layer
        and distance < properties.detection_distance
      local near_hero_md = layer == hero_layer
        and distance < properties.max_distance --md: max distance
      if near_hero then
        if properties.state == "asleep"  then
          self:wake_up()
        elseif properties.state == "wake_up" and properties.straight == false then
          print("TEST NAMES in enemy:check() wake_up: ", self:get_name(), properties.leader_name)
          if self:get_name() == properties.leader_name then
            self:go_hero()
          else
            self:go_leader()
          end
        elseif properties.state == "wake_up" and properties.straight == true then
          properties.state = "stopped"
        elseif properties.state == "going_random" and properties.straight == false then
          print("TEST NAMES in enemy:on_restarted() going_random: ", self:get_name(), properties.leader_name)
          if self:get_name() == properties.leader_name then
            self:go_hero()
          else
            self:go_leader()
          end
        elseif properties.state == "stopped" and properties.straight == true then
          if math.abs(dy) < properties.detection_distance then
            if dx > 0 then
              self:go_straight(0)
            else
              self:go_straight(2)
            end
          end
          if math.abs(dx) < properties.detection_distance then
            if dy > 0 then
              self:go_straight(3)
            else
              self:go_straight(1)
            end
          end
         end
      else
        if near_hero_md == false and (properties.state == "going_hero" or properties.state == "going_leader") then
          if self:get_name() == properties.leader_name then
            self:go_random()
          else
            self:go_leader()
          end
        end
      end
      sol.timer.stop_all(self)
      sol.timer.start(self, 1000, function() self:check_hero() end)
      return true
    end)
  end

  function enemy:on_hurt()

    print("HURT: ", self:get_name())
  end

  function enemy:asleep()

    properties.state = "asleep"
    self:stop_movement()
    local sprite = self:get_sprite()
    sprite:set_animation(properties.asleep_animation)
  end


  function enemy:wake_up()

    properties.state = "wake_up"
    self:stop_movement()
    local sprite = self:get_sprite()
    sprite:set_animation(properties.awaking_animation)
    if properties.awakening_sound ~= nil then
      sol.audio.play_sound(properties.awakening_sound)
    end
  end

  function enemy:go_random()

print("enemy:go_random()")
    properties.state = "going_random"
    local m = sol.movement.create("random")
    m:set_speed(properties.normal_speed)
    m:start(self)
  end

  function enemy:go_hero()

print("enemy:go_hero()")
    properties.state = "going_hero"
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:start(self)
  end



  function enemy:test_collision()

    local hero = self:get_map():get_entity("hero")
    local map = self:get_map()
    local x, y, layer = self:get_position()
    local dx, dy, dlayer = self:get_facing_position()
    -- entity:get_angle(x, y), entity:get_angle(other_entity)
    -- entity:get_distance(x, y), entity:get_distance(other_entity)
    local angle = self:get_angle(hero)
    local distance = self:get_distance(hero)
    local hero_x, hero_y, hero_layer = hero:get_position()
    local has_collision = self:test_obstacles(dx, dx, dlayer)
    local entity = self:get_facing_entity()
    print("test_collision > ", "x: ", x, "y:", y, "layer ", layer, "dx: ", dx, "dy: ", dy, "dlayer: ", dlayer, has_collision, entity)
  end




  function enemy:go_leader()

self:test_collision()
print("enemy:go_leader(avant)")
    local map = self:get_map()
    if properties.leader_name == nil then
print("enemy:go_leader(apres mais nil)")
    else
print("enemy:go_leader(apres)", properties.leader_name)
      if map:has_entity(properties.leader_name) then
        properties.state = "going_leader"
        local entity = map:get_entity(properties.leader_name)
        local m = sol.movement.create("path_finding")
        m:set_target(entity)
        -- m:set_target(entity, 80, 0)
        m:set_speed(properties.faster_speed)
        -- m:set_smooth(true)
        m:start(self)
      end
    end
  end

 function enemy:go_straight(direction4)

   local dxy = {
     { x =  8, y =  0},
     { x =  0, y = -8},
     { x = -8, y =  0},
     { x =  0, y =  8}
   }
   self:set_traversable(traversable)
   local sprite = self:get_sprite()
   sprite:set_animation(properties.attack_animation, properties.stopped_animation)
   local index = direction4 + 1
   if not self:test_obstacles(dxy[index].x * 2, dxy[index].y * 2) then
     properties.state = "going_straight"
     local x, y = self:get_position()
     local angle = direction4 * math.pi / 2
     local m = sol.movement.create("straight")
     m:set_speed(properties.faster_speed)
     m:set_angle(angle)
     m:set_max_distance(properties.max_distance)
     m:set_smooth(false)
     m:start(self)
   end
 end

  function enemy:go_back()

    if properties.state == "going_straight" then
      properties.state = "going_back"
      local m = sol.movement.create("target")
      m:set_speed(properties.faster_speed )
      m:set_target(properties.initial_xy.x, properties.initial_xy.y)
      m:set_smooth(false)
      m:start(self)
      --sol.audio.play_sound("sword_tapping")
    elseif properties.state == "going_back" then
      properties.state = "paused"
      sol.timer.start(self, 500, function() self:unpause() end)
    end
  end

  function enemy:unpause()

    properties.state = "stopped"
  end

end
