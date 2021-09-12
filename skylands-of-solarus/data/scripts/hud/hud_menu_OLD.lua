-- The background of the hud shown in the game screen.

require("scripts/multi_events")

local hud_menu_builder = {}


function hud_menu_builder:new(game, config)

  local hud_menu = {}
  hud_menu.choice = game:get_value("hud")
  local colors = {{15, 31, 31}, { 48, 111, 80 }, {143, 192, 112}, { 224, 255, 208 }}
  hud_menu.dst_x, hud_menu.dst_y = config.x, config.y
  hud_menu.dst_w, hud_menu.dst_h = sol.video.get_quest_size()
  hud_menu.camera_w = 240
  hud_menu.camera_h = 160
  hud_menu.tile = 8
  hud_menu.left_w = (hud_menu.dst_w - hud_menu.camera_w) / 2
  -- Creation of surfaces
  local file = "hud/menu_" .. hud_menu.choice .. ".png"
  hud_menu.img = sol.surface.create(file)
  hud_menu.surface = sol.surface.create(hud_menu.dst_w, hud_menu.dst_h)
  hud_menu.surface_top_left = sol.surface.create(48, 44)
  hud_menu.surface_top_left:fill_color(colors[hud_menu.choice])
  hud_menu.surface_bot_left = sol.surface.create(48, 4)
  hud_menu.surface_bot_left:fill_color(colors[hud_menu.choice])
  hud_menu.surface_top_right = sol.surface.create(48, 200)
  hud_menu.surface_top_right:fill_color(colors[hud_menu.choice])
  hud_menu.submenus_icon_bg_sprite = sol.sprite.create("menus/pause/submenus_icon_bg")
  hud_menu.inventory_icon = sol.surface.create("menus/pause/inventory_icon.png")

  -- 
  function hud_menu:check()

    local need_rebuild = false

    if game:is_paused() then
        hud_menu.submenus_icon_bg_sprite:set_animation("activated")
      else
        hud_menu.submenus_icon_bg_sprite:set_animation("inactivated")
    end

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

    --local sel_shader
    local xs = 8 -- x of slots
    local ys = 44 -- y of slots
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
    hud_menu.surface_top_left:draw(dst_surface, 8, 8)
    hud_menu.surface_bot_left:draw(dst_surface, 8, 204)
    hud_menu.surface_top_right:draw(dst_surface, 328, 8)
    while xs < 48 and ys < 204 do
      hud_menu.img:draw_region(0, 16, 16, 16, dst_surface, xs, ys)
      xs = xs + 16
      if xs % 48 == 8 then
        xs = 8
        ys = ys + 16
      end
    end
    hud_menu.submenus_icon_bg_sprite:draw(dst_surface, 32, 24)
    hud_menu.inventory_icon:draw(dst_surface, 20, 13)
  end


  function hud_menu:on_started()

    hud_menu:check()
    hud_menu:rebuild_surface()
  end

  return hud_menu
end

return hud_menu_builder
