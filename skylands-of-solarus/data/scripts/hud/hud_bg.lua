-- The background of the hud shown in the game screen.

require("scripts/multi_events")

local hud_bg_builder = {}


function hud_bg_builder:new(game, config)

  local hud_bg = {}
  hud_bg.choice = game:get_value("hud")
  local colors = {{15, 31, 31}, { 48, 111, 80 }, {143, 192, 112}, { 224, 255, 208 }}
  hud_bg.dst_x, hud_bg.dst_y = config.x, config.y
  hud_bg.dst_w, hud_bg.dst_h = sol.video.get_quest_size()
  hud_bg.camera_w = 240
  hud_bg.camera_h = 160
  hud_bg.tile = 8
  hud_bg.top_h = 40
  hud_bg.bot_h = hud_bg.dst_h - hud_bg.camera_h - hud_bg.top_h
  hud_bg.x2 = (hud_bg.dst_w - hud_bg.camera_w) / 2
  hud_bg.x1 = hud_bg.x2 - hud_bg.tile
  hud_bg.x3 = hud_bg.dst_w - hud_bg.x2
  hud_bg.y1 = hud_bg.top_h - hud_bg.tile
  hud_bg.y2 = hud_bg.top_h + hud_bg.tile
  hud_bg.y3 = hud_bg.top_h + hud_bg.camera_h
  hud_bg.y4 = hud_bg.top_h + hud_bg.camera_h + hud_bg.tile
  -- Creation of surfaces
  local file = "hud/bg_" .. hud_bg.choice .. ".png"
  hud_bg.img = sol.surface.create(file)
  hud_bg.surface_top = sol.surface.create(hud_bg.camera_w, hud_bg.top_h - hud_bg.tile)
  hud_bg.surface_top:fill_color(colors[hud_bg.choice])
  hud_bg.surface_bot = sol.surface.create(hud_bg.camera_w, hud_bg.bot_h - hud_bg.tile)
  hud_bg.surface_bot:fill_color(colors[hud_bg.choice])
  hud_bg.surface = sol.surface.create(hud_bg.dst_w, hud_bg.dst_h)


  function hud_bg:check()

    --local need_rebuild = false

    -- Redraw the surface only if something has changed.
    --if need_rebuild then
    --  hud_bg:rebuild_surface()
    --end

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

    local sel_shader
    local x = hud_bg.x2
    local yt = hud_bg.tile -- top
    local yc = hud_bg.y2 -- y of tiles along the camera
    local yb = hud_bg.y4 -- bottom
    -- top
    hud_bg.img:draw_region(0, 0, 8, 8, dst_surface, hud_bg.x1, 0)
    hud_bg.img:draw_region(16, 0, 8, 8, dst_surface, hud_bg.x3, 0)
    while yt < hud_bg.y1 do
      hud_bg.img:draw_region(0, 8, 8, 8, dst_surface, hud_bg.x1, yt)
      hud_bg.img:draw_region(16, 8, 8, 8, dst_surface, hud_bg.x3, yt)
      yt = yt + hud_bg.tile
    end
    hud_bg.img:draw_region(0, 16, 8, 16, dst_surface, hud_bg.x1, hud_bg.y1)
    hud_bg.img:draw_region(16, 16, 8, 16, dst_surface, hud_bg.x3, hud_bg.y1)
    -- along the camera (vertical)
    while yc < hud_bg.y3 do
      hud_bg.img:draw_region(0, 32, 8, 8, dst_surface, hud_bg.x1, yc)
      hud_bg.img:draw_region(16, 32, 8, 8, dst_surface, hud_bg.x3, yc)
      yc = yc + hud_bg.tile
    end
    -- top and bottom (horizontal)
    while x < hud_bg.x3 do
      hud_bg.surface_top:draw(dst_surface, hud_bg.x2, 0)
      hud_bg.img:draw_region(8, 16, 8, 8, dst_surface, x, hud_bg.y1)
      hud_bg.img:draw_region(8, 40, 8, 8, dst_surface, x, hud_bg.y3)
      hud_bg.surface_bot:draw(dst_surface, hud_bg.x2, hud_bg.y4)
      x = x + hud_bg.tile
    end
    -- bottom
    if hud_bg.bot_h > (hud_bg.tile * 2) then
      hud_bg.img:draw_region(0, 40, 8, 8, dst_surface, hud_bg.x1, hud_bg.y3)
      hud_bg.img:draw_region(16, 40, 8, 8, dst_surface, hud_bg.x3, hud_bg.y3)
      while yb < hud_bg.dst_h do
        hud_bg.img:draw_region(0, 8, 8, 8, dst_surface, hud_bg.x1, yb)
        hud_bg.img:draw_region(16, 8, 8, 8, dst_surface, hud_bg.x3, yb)
        yb = yb + hud_bg.tile
       end
    else
      hud_bg.img:draw_region(0, 40, 8, 16, dst_surface, hud_bg.x1, hud_bg.y3)
      hud_bg.img:draw_region(16, 40, 8, 16, dst_surface, hud_bg.x3, hud_bg.y3)
    end
  end


  function hud_bg:on_started()

    hud_bg:check()
    hud_bg:rebuild_surface()
  end

  return hud_bg
end

return hud_bg_builder
