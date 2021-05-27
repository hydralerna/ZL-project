-- The rupee counter shown in the game screen.

local text_fx_helper = require("scripts/text_fx_helper")

local rupees_builder = {}

function rupees_builder:new(game, config)

  local rupees = {}

  rupees.dst_x, rupees.dst_y = config.x, config.y
  rupees.surface = sol.surface.create(32, 14)
  rupees.text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "enter_command",
    color = {48, 111, 80},
    font_size = 16,
  })
  rupees.font_fx_color = {143, 192, 112}
  rupees.text_surface:set_text(game:get_rupee())
  rupees.rupee_icons_img = sol.surface.create("hud/rupee_icon.png")
  rupees.rupee_bag_displayed = game:get_item("money_bag"):get_variant()
  rupees.rupee_displayed = game:get_rupee()

  function rupees:check()

    local need_rebuild = false
    local rupee_bag = game:get_item("money_bag"):get_variant()
    local rupee = game:get_rupee()

    -- Max rupee.
    if rupee_bag ~= rupees.rupee_bag_displayed then
      need_rebuild = true
      rupees.rupee_bag_displayed = rupee_bag
    end

    -- Current rupee.
    if rupee ~= rupees.rupee_displayed then
      need_rebuild = true
      local increment
      if rupee > rupees.rupee_displayed then
        increment = 1
      else
        increment = -1
      end
      rupees.rupee_displayed = rupees.rupee_displayed + increment

      -- Play a sound if we have just reached the final value.
      if rupees.rupee_displayed == rupee then
        sol.audio.play_sound("picked_rupee")

      -- While the counter is scrolling, play a sound every 3 values.
      elseif rupees.rupee_displayed % 3 == 0 then
        sol.audio.play_sound("picked_rupee")
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      rupees:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(rupees, 40, function()
      rupees:check()
    end)
  end


  function rupees:rebuild_surface()

    rupees.surface:clear()
    -- Max rupee (icon).
    rupees.rupee_icons_img:draw_region(0, 0, 7, 13, rupees.surface)
    -- Current rupee (counter).
    local max_rupee = game:get_max_rupee()
    rupees.text_surface:set_text(rupees.rupee_displayed)
    rupees.text_surface:set_xy(10, 6)
    if rupees.rupee_displayed == max_rupee then
      text_fx_helper:draw_text_with_stroke(rupees.surface, rupees.text_surface, rupees.font_fx_color)
    else
      text_fx_helper:draw_text_with_shadow(rupees.surface, rupees.text_surface, rupees.font_fx_color)
    end
  end


  function rupees:get_surface()

    return rupees.surface
  end


  function rupees:on_draw(dst_surface)

    local x, y = rupees.dst_x, rupees.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end
    rupees.surface:draw(dst_surface, x, y)
  end


  function rupees:on_started()

    rupees:check()
    rupees:rebuild_surface()
  end

  return rupees
end

return rupees_builder
