-- Hearts view for the enemy used in game screen

local e_hearts_builder = {}

function e_hearts_builder:new(game, config)

  local e_hearts = {}

  if config ~= nil then
    e_hearts.dst_x, e_hearts.dst_y = config.x, config.y
  end

  e_hearts.surface = sol.surface.create(100, 19)
  e_hearts.empty_heart_sprite = sol.sprite.create("hud/empty_heart_enemy")
  e_hearts.nb_max_hearts_displayed = game:get_max_life() / 4
  e_hearts.nb_current_hearts_displayed = game:get_life()
  e_hearts.all_hearts_img = sol.surface.create("hud/hearts_enemy.png")

  function e_hearts:on_started()

    -- This function is called when the HUD starts or
    -- was disabled and gets enabled again.
    -- Unlike other HUD elements, the timers were canceled because they
    -- are attached to the menu and not to the game
    -- (this is because the hearts are also used in the savegame menu).

    -- After game-over don't show gradually getting the life back.
    e_hearts.nb_current_hearts_displayed = game:get_life()
    e_hearts.danger_sound_timer = nil
    e_hearts:check()
    e_hearts:rebuild_surface()
  end

  -- Checks whether the view displays the correct info
  -- and updates it if necessary.
  function e_hearts:check()

    local need_rebuild = false

    -- Maximum life.
    local nb_max_hearts = game:get_max_life() / 4
    if nb_max_hearts ~= e_hearts.nb_max_hearts_displayed then
      need_rebuild = true

      if nb_max_hearts < e_hearts.nb_max_hearts_displayed then
        -- Decrease immediately if the max life is reduced.
        e_hearts.nb_current_hearts_displayed = game:get_life()
      end

      e_hearts.nb_max_hearts_displayed = nb_max_hearts
    end

    -- Current life.
    local nb_current_hearts = game:get_life()
    if nb_current_hearts ~= e_hearts.nb_current_hearts_displayed then

      need_rebuild = true
      if nb_current_hearts < e_hearts.nb_current_hearts_displayed then
        e_hearts.nb_current_hearts_displayed = e_hearts.nb_current_hearts_displayed - 1
      else
        e_hearts.nb_current_hearts_displayed = e_hearts.nb_current_hearts_displayed + 1
        if game:is_started()
            and e_hearts.nb_current_hearts_displayed % 4 == 0 then
          sol.audio.play_sound("heart")
        end
      end
    end

    -- If we are in-game, play an animation and a sound if the life is low.
    if game:is_started() then

      if game:get_life() <= game:get_max_life() / 4
          and not game:is_suspended() then
        need_rebuild = true
        if e_hearts.empty_heart_sprite:get_animation() ~= "danger" then
          e_hearts.empty_heart_sprite:set_animation("danger")
        end
        if e_hearts.danger_sound_timer == nil then
          e_hearts.danger_sound_timer = sol.timer.start(self, 250, function()
            e_hearts:repeat_danger_sound()
          end)
          e_hearts.danger_sound_timer:set_suspended_with_map(true)
        end
      elseif e_hearts.empty_heart_sprite:get_animation() ~= "normal" then
        need_rebuild = true
        e_hearts.empty_heart_sprite:set_animation("normal")
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      e_hearts:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(hearts, 50, function()
      e_hearts:check()
    end)
  end

  function e_hearts:repeat_danger_sound()

    if game:get_life() <= game:get_max_life() / 4 then

      sol.audio.play_sound("misc/low_health") --danger
      e_hearts.danger_sound_timer = sol.timer.start(hearts, 750, function()
        e_hearts:repeat_danger_sound()
      end)
      e_hearts.danger_sound_timer:set_suspended_with_map(true)
    else
      e_hearts.danger_sound_timer = nil
    end
  end

  function e_hearts:rebuild_surface()
    e_hearts.surface:clear()

    -- Display the hearts.
    for i = 0, e_hearts.nb_max_hearts_displayed - 1 do
      local x, y = (i % 10) * 10, math.floor(i / 10) * 10
      e_hearts.empty_heart_sprite:draw(e_hearts.surface, x, y)
      if i < math.floor(e_hearts.nb_current_hearts_displayed / 4) then
        -- This heart is full.
        e_hearts.all_hearts_img:draw_region(27, 0, 9, 9, e_hearts.surface, x, y)
      end
    end

    -- Last fraction of heart.
    local i = math.floor(e_hearts.nb_current_hearts_displayed / 4)
    local remaining_fraction = e_hearts.nb_current_hearts_displayed % 4
    if remaining_fraction ~= 0 then
      local x, y = (i % 10) * 10, math.floor(i / 10) * 10
      e_hearts.all_hearts_img:draw_region((remaining_fraction - 1) * 9, 0, 9, 9, e_hearts.surface, x, y)
    end
  end

  function e_hearts:set_dst_position(x, y)
    e_hearts.dst_x = x
    e_hearts.dst_y = y
  end

  function e_hearts:get_surface()
    return e_hearts.surface
  end

  function e_hearts:on_draw(dst_surface)

    local x, y = e_hearts.dst_x, e_hearts.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    -- Everything was already drawn on self.surface.
    e_hearts.surface:draw(dst_surface, x, y)
  end

  e_hearts:rebuild_surface()

  return hearts
end

return e_hearts_builder
