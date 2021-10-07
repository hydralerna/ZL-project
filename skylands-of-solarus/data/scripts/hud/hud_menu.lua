-- The background of the hud shown in the game screen.

require("scripts/multi_events")

local hud_menu_builder = {}


function hud_menu_builder:new(game, config)

  local hud_menu = {}
  hud_menu.color = game:get_value("color") or 1
  local colors = {{15, 31, 31}, { 48, 111, 80 }, {143, 192, 112}, { 224, 255, 208 }}
  hud_menu.dst_x, hud_menu.dst_y = config.x, config.y
  hud_menu.dst_w, hud_menu.dst_h = sol.video.get_quest_size()
  hud_menu.camera_w = 240
  hud_menu.camera_h = 160
  hud_menu.tile = 8
  hud_menu.left_w = (hud_menu.dst_w - hud_menu.camera_w) / 2
  -- Creation of surfaces
  local file = "hud/menu_" .. hud_menu.color .. ".png"
  hud_menu.img = sol.surface.create(file)
  hud_menu.surface = sol.surface.create(hud_menu.dst_w, hud_menu.dst_h)
  hud_menu.surface_top = sol.surface.create(48, 44)
  hud_menu.surface_top:fill_color(colors[hud_menu.color])
  hud_menu.surface_mid = sol.surface.create(48, 48)
  hud_menu.surface_mid:fill_color(colors[hud_menu.color])
  hud_menu.surface_bot = sol.surface.create(48, 4)
  hud_menu.surface_bot:fill_color(colors[hud_menu.color])
  hud_menu.submenus_icon_bg_sprite = sol.sprite.create("menus/pause/submenus_icon_bg_" .. hud_menu.color)
  hud_menu.submenus_icon_bg_sprite:set_animation("idle")
  hud_menu.inventory_icon = sol.surface.create("menus/pause/inventory_icon_".. hud_menu.color .. ".png")
  hud_menu.emoji_icon = sol.surface.create("menus/pause/emoji_icon_".. hud_menu.color .. ".png")

  -- 
  function hud_menu:check()

    local need_rebuild = false

    --if game:is_paused() then
    --    hud_menu.submenus_icon_bg_sprite:set_animation("activated")
    --  else
    --    hud_menu.submenus_icon_bg_sprite:set_animation("inactivated")
    --end

    -- Redraw the surface only if something has changed.
    --if need_rebuild then
    --  hud_menu:rebuild_surface()
    --end

    -- Schedule the next check.
    sol.timer.start(hud_menu, 40, function()
      hud_menu:check()
    end)
  end


  function hud_menu:rebuild_surface()

    hud_menu.surface:clear()
  end


  function hud_menu:get_surface()

    return hud_menu.surface
  end


  function hud_menu:on_draw(dst_surface)

    local x1 = 8
    local x6 = 328
    local y1 = 8
    while y1 < 208 do
      hud_menu.img:draw_region(0, 8, 8, 8, dst_surface, 0, y1)
      hud_menu.img:draw_region(8, 0, 8, 8, dst_surface, 56, y1)
      hud_menu.img:draw_region(0, 8, 8, 8, dst_surface, 320, y1)
      hud_menu.img:draw_region(8, 0, 8, 8, dst_surface, 376, y1)
      y1 = y1 + hud_menu.tile
    end
    hud_menu.img:draw_region(48, 0, 8, 8, dst_surface, 0, 0)
    hud_menu.img:draw_region(56, 0, 8, 8, dst_surface, 56, 0)
    hud_menu.img:draw_region(64, 0, 8, 8, dst_surface, 320, 0)
    hud_menu.img:draw_region(72, 0, 8, 8, dst_surface, 376, 0)
    while x1 < 56 do
      hud_menu.img:draw_region(0, 0, 8, 8, dst_surface, x1, 0)
      hud_menu.img:draw_region(8, 8, 8, 8, dst_surface, x1, 208)
      x1 = x1 + hud_menu.tile
    end
    while x6 < 376 do
      hud_menu.img:draw_region(0, 0, 8, 8, dst_surface, x6, 0)
      hud_menu.img:draw_region(8, 8, 8, 8, dst_surface, x6, 208)
      x6 = x6 + hud_menu.tile
    end
    hud_menu.img:draw_region(48, 8, 8, 8, dst_surface, 0, 208)
    hud_menu.img:draw_region(56, 8, 8, 8, dst_surface, 56, 208)
    hud_menu.img:draw_region(64, 8, 8, 8, dst_surface, 320, 208)
    hud_menu.img:draw_region(72, 8, 8, 8, dst_surface, 376, 208)
    -- Left
    hud_menu.surface_top:draw(dst_surface, 8, 8)
    hud_menu.surface_bot:draw(dst_surface, 8, 204)
    -- Right
    hud_menu.surface_top:draw(dst_surface, 328, 8)
    hud_menu.surface_mid:draw(dst_surface, 328, 108)
    hud_menu.surface_bot:draw(dst_surface, 328, 204)

    -- Slots
    for ys1 = 44, 188, 16 do
      for xs1 = 8, 40, 16 do
        hud_menu.img:draw_region(0, 16, 16, 16, dst_surface, xs1, ys1)
        xs1 = xs1 + 16
      end
    end
    for ys2 = 44, 188, 16 do
      for xs2 = 328, 360, 16 do
        if ys2 < 108 or ys2 > 140 then
          hud_menu.img:draw_region(0, 16, 16, 16, dst_surface, xs2, ys2)
        end
        xs2 = xs2 + 16
      end
    end
    --
    hud_menu.submenus_icon_bg_sprite:draw(dst_surface, 32, 24)
    hud_menu.submenus_icon_bg_sprite:draw(dst_surface, 352, 24)
    hud_menu.inventory_icon:draw(dst_surface, 20, 13)
    hud_menu.emoji_icon:draw(dst_surface, 340, 13)
  end


  function hud_menu:on_started()

    hud_menu:check()
    hud_menu:rebuild_surface()
  end

  return hud_menu
end

return hud_menu_builder
