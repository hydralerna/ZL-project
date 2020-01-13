-- The background of the hud shown in the game screen.

local hud_bg_builder = {}

function hud_bg_builder:new(game, config)

  local hud_bg = {}
  hud_bg.dst_x, hud_bg.dst_y = config.x, config.y
  hud_bg.dst_w, hud_bg.dst_h = sol.video.get_quest_size()
  hud_bg.bg_img = sol.surface.create("hud/bg.png")
  hud_bg.tile_w, hud_bg.tile_h = hud_bg.bg_img:get_size()
  hud_bg.tile_h = hud_bg.tile_h / 2
  hud_bg.surface = sol.surface.create(hud_bg.dst_w, hud_bg.dst_h)


  function hud_bg:check()

    local need_rebuild = false

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      hud_bg:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(hud_bg, 40, function()
      hud_bg:check()
    end)
  end

  function hud_bg:rebuild_surface()

    hud_bg.surface:clear()

  end

  function hud_bg:get_surface()

    return hud_bg.surface
  end

  function hud_bg:on_draw(dst_surface)

    local x = 0
	local y = hud_bg.dst_h - hud_bg.tile_h
	while x < hud_bg.dst_w do
		hud_bg.bg_img:draw_region(0, 0, hud_bg.tile_w, hud_bg.tile_h, dst_surface, x, 0)
		hud_bg.bg_img:draw_region(0, hud_bg.tile_h, hud_bg.tile_w, hud_bg.tile_h, dst_surface, x, y)
		x = x + hud_bg.tile_w
	end
    -- hud_bg.surface:draw(dst_surface, x, y)
  end

  function hud_bg:on_started()
    hud_bg:check()
    hud_bg:rebuild_surface()
  end

  return hud_bg
end

return hud_bg_builder
