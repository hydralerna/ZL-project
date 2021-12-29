-- Hearts view for the boss used in game screen
-- WIP

local b_hearts_builder = {}

function b_hearts_builder:new(game, config)

  local b_hearts = {}

  if config ~= nil then
    b_hearts.dst_x, b_hearts.dst_y = config.x, config.y
  end
  b_hearts.surface = sol.surface.create(100, 19)
  b_hearts.empty_heart_sprite = sol.sprite.create("hud/empty_b_heart")
  b_hearts.all_hearts_img = sol.surface.create("hud/b_hearts.png")
  b_hearts.is_restarted = true
  b_hearts.enabled = false


  function b_hearts:on_started()

    -- This function is called when the HUD starts or
    -- was disabled and gets enabled again.
    -- After game-over don't show gradually getting the life back.
    if b_hearts.starting_life ~= nil then
      b_hearts.boss:set_life(b_hearts.starting_life)
      b_hearts.enabled = true
      b_hearts.is_restarted = true
    end
    b_hearts:check()
    b_hearts:rebuild_surface()
  end


  -- Checks whether the view displays the correct info
  -- and updates it if necessary.
  function b_hearts:check()

    local need_rebuild = false

    -- Display is activated if there is a boss in the map
    local map = game:get_map()
    if map == nil then
      need_rebuild = true
    else
      local map_id = map:get_id()
      if b_hearts.is_restarted then
        if map:has_entity("boss") then
            b_hearts.boss = map:get_entity("boss")
            b_hearts.starting_life = b_hearts.boss:get_life()
            b_hearts.nb_max_hearts_displayed = b_hearts.starting_life
            b_hearts.nb_current_hearts_displayed = b_hearts.starting_life
            if b_hearts.is_restarted then
              b_hearts.is_restarted = false
            end
            need_rebuild = true
        end
      end
    end

    -- If display is activated...
    if b_hearts.enabled then
      -- Current life of the boss.
      local nb_current_hearts = b_hearts.boss:get_life()
      if nb_current_hearts ~= b_hearts.nb_current_hearts_displayed then
        need_rebuild = true
        if nb_current_hearts < b_hearts.nb_current_hearts_displayed then
          b_hearts.nb_current_hearts_displayed = b_hearts.nb_current_hearts_displayed - 1
        else
          b_hearts.nb_current_hearts_displayed = b_hearts.nb_current_hearts_displayed + 1
          if game:is_started() and b_hearts.nb_current_hearts_displayed % 4 == 0 then
            sol.audio.play_sound("items/get_item")
          end
        end
      end

      -- If we are in-game, play a different animation according to the points of life.
      if game:is_started() then
        if b_hearts.boss:get_life() <= (b_hearts.nb_max_hearts_displayed / 4) then
          need_rebuild = true
          if b_hearts.boss:get_life() == 0 then
            if b_hearts.timer == nil then
              b_hearts.timer = sol.timer.start(self, 4500, function()
                if b_hearts.empty_heart_sprite:get_animation() ~= "explosion" then
                  b_hearts.empty_heart_sprite:set_animation("explosion")
                end
              end)
              b_hearts.timer:set_suspended_with_map(true)
            end
          elseif b_hearts.empty_heart_sprite:get_animation() ~= "danger" then
              b_hearts.empty_heart_sprite:set_animation("danger")
          end
        elseif b_hearts.empty_heart_sprite:get_animation() ~= "normal" then
          need_rebuild = true
          b_hearts.empty_heart_sprite:set_animation("normal")
        end
      end
    end -- (Display)

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      b_hearts:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(b_hearts, 50, function()
      b_hearts:check()
    end)
  end


  -- Function to enable or disable the boss's hud
  function game:set_b_hearts_hud_enabled(enabled)

    if enabled then
      b_hearts.enabled = true
    else
      b_hearts.enabled = false
    end
    b_hearts:rebuild_surface()
  end

  -- Function to get the status (true or false) of the boss's hud
  function game:get_b_hearts_hud_enabled()

      return b_hearts.enabled
  end

  -- Function to rebuild the surface
  function b_hearts:rebuild_surface()

    b_hearts.surface:clear()
    if b_hearts.enabled then

      -- Display the hearts.
      for i = 0, (b_hearts.nb_max_hearts_displayed / 4) - 1 do
        local x, y = (i % 10) * 10, math.floor(i / 10) * 10
        b_hearts.empty_heart_sprite:draw(b_hearts.surface, x, y)
        if i < math.floor(b_hearts.nb_current_hearts_displayed / 4) then
          -- This heart is full.
          b_hearts.all_hearts_img:draw_region(27, 0, 9, 9, b_hearts.surface, x, y)
        end
      end
      -- Last fraction of heart.
      local i = math.floor(b_hearts.nb_current_hearts_displayed / 4)
      local remaining_fraction = b_hearts.nb_current_hearts_displayed % 4
      if remaining_fraction ~= 0 then
        local x, y = (i % 10) * 10, math.floor(i / 10) * 10
        b_hearts.all_hearts_img:draw_region((remaining_fraction - 1) * 9, 0, 9, 9, b_hearts.surface, x, y)
      end
    end
  end


  
  -- function b_hearts:set_dst_position(x, y)

   --  b_hearts.dst_x = x
   --  b_hearts.dst_y = y
  -- end


  -- function b_hearts:get_surface()

   --  return b_hearts.surface
  -- end


  -- Function to draw the surface
  function b_hearts:on_draw(dst_surface)

    local x, y = b_hearts.dst_x, b_hearts.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end
    -- Everything was already drawn on self.surface.
    b_hearts.surface:draw(dst_surface, x, y)
  end
  b_hearts:rebuild_surface()
  return b_hearts
end

return b_hearts_builder
