-- The chrono shown in the game screen.
local text_fx_helper = require("scripts/text_fx_helper")

local chrono_builder = {}

function chrono_builder:new(game, config)

  local chrono = {}

  -- Resets the timer.
  function chrono:reset_timer()

    if chrono.timer ~= nil then
      chrono.timer:stop()
      chrono.timer = nil
    end
  end

  chrono:reset_timer()
  chrono.threshold_seconds = 15
  chrono.offset = 2
  chrono.zero = false
  chrono.seconds_displayed = chrono.threshold_seconds
  chrono.dst_x, chrono.dst_y = config.x, config.y
  -- chrono.width, chrono.height = sol.video.get_quest_size()
  -- chrono.map_surface = sol.surface.create(chrono.width, chrono.height - 32)
  chrono.surface = sol.surface.create(34, 15)
  chrono.px_surface = sol.surface.create(2, 2)
  chrono.px_surface:fill_color({143, 192, 112})
  chrono.text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "enter_command",
    color = {143, 192, 112},
    font_size = 16,
  })
  chrono.font_fx_color = {48, 111, 80}
  chrono.text_surface:set_text(chrono.threshold_seconds)
  chrono.chrono_icons_img = sol.surface.create("hud/icon_chrono.png")
	chrono.timer = sol.timer.start(chrono.threshold_seconds * 1000, function()
      sol.audio.play_sound("wrong")
	end)
  --KO--chrono.timer:set_suspended_with_map()
  chrono.timer2 = sol.timer.start((chrono.threshold_seconds + chrono.offset) * 1000, function()
      chrono:check()
      chrono:rebuild_surface()
      sol.audio.play_sound("explosion")
      game:set_life(0)

      chrono.zero = true
	end)
  --KO--chrono.timer2:set_suspended_with_map()

  function chrono:on_started()

    chrono:check()
    chrono:rebuild_surface()
  end


  -- s (second), t (timing), d (display; add 1 second or not for display)
  function chrono:get_remain_seconds()

    local s = chrono.timer:get_remaining_time() / 1000
    local d = 1
    local t = 30000
    if s == 0 then
      d = 0
    else
      s = math.floor(s)
      if s >= 1 and s <= 5 then
          t = 1000
      elseif s > 5 and s < 30 then
          t = 5000
      elseif s >= 30 and s <= 60 then
          t = 10000
      end
      if math.fmod(chrono.timer:get_remaining_time(), t) == 0 then
         sol.audio.play_sound("timer")
      end
    end
    return s + d
  end


  function chrono:check()

    local need_rebuild = false
    local second = chrono:get_remain_seconds(chrono.timer)
    if second ~= chrono.seconds_displayed or chrono.timer2:get_remaining_time() == 0 and not chrono.zero then
      need_rebuild = true
      chrono.seconds_displayed = second
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      chrono:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(chrono, 50, function()
      chrono:check()
    end)
  end


  function chrono:rebuild_surface()

    chrono.surface:clear()
  end


  function chrono:get_surface()

    return chrono.px_surface
  end


  function chrono:on_draw(dst_surface)

    --local x, y, r = 0, 0, 8
    local x, y = chrono.dst_x, chrono.dst_y
    local second = chrono:get_remain_seconds(chrono.timer)
    local second2 = math.floor(chrono.timer2:get_remaining_time())
    local text = string.format("%03d", second)
    -- local unit = math.floor(360 / chrono.threshold_seconds)
    chrono.chrono_icons_img:draw_region(3, 6, 34, 15, dst_surface, x, y)
    chrono.surface:draw(dst_surface, x, y)

    if second == 0 and second2 == 0 then
       --chrono.map_surface:draw(dst_surface, 0, 16)
       --chrono.map_surface:fill_color({224, 255, 208})
       chrono.text_surface:set_text("BOOM")
       chrono.text_surface:set_xy(5, 6)
    else
       chrono.chrono_icons_img:draw_region(0, 24, 9, 8, dst_surface, x + 3, y + 3)
       chrono.text_surface:set_text(text)
       chrono.text_surface:set_xy(13, 6)
    end
    text_fx_helper:draw_text_with_shadow(chrono.surface, chrono.text_surface, chrono.font_fx_color)
    --for i = -90, ((second * unit) - (90 + unit)), unit do
    --  local angle = i * math.pi / 180
    --  local ptx, pty = x + r * math.cos(angle), y + r * math.sin(angle)
     -- chrono.px_surface:draw_region(0, 0, 2, 2, chrono.surface, ptx, pty)
     -- chrono.px_surface:fill_color({143, 192, 112})
      -- print(ptx, pty)
    --end
  end

  return chrono
end

return chrono_builder

