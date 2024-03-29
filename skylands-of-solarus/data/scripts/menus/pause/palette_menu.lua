-- WIP

local submenu = require("scripts/menus/pause/pause_submenu")
local game_manager = require("scripts/game_manager")
local index_palette_shader = require("scripts/index_palette_shader")
local info_manager = require("scripts/info_manager")
local text_fx_helper = require("scripts/text_fx_helper")

local palette_menu = submenu:new()

-- Function to get the next value. Code by cluedrew
local function ring_next(minimum, maximum, current, isDecreasing)

    if isDecreasing and current == minimum then
        return maximum
    elseif isDecreasing then
        return current - 1
    elseif current == maximum then
        return minimum
    else
        return current + 1
    end
end
--

function palette_menu:on_started()

  sol.video.set_shader(nil)
  self.tab = 2

  self.palette_img = sol.surface.create("shaders/palette.png")
  self.palette_w, self.palette_h = self.palette_img:get_size()

  index_palette_shader:set_palette(submenu.surface)
  index_palette_shader:set_palette(submenu.img)

  --self.menu_tabs_img = sol.surface.create("menus/menu_tabs.png")
  --index_palette_shader:set_palette(self.menu_tabs_img)

  -- Create an array containing all the 4-color palettes. From the code by llamazing.
  local pixels = self.palette_img:get_pixels()
  local length = pixels:len() -- 4 bytes (R, G, B, A) for each pixel
  self.palette_array = {}
  for i=1,length,16 do
    local pixel_bytes = pixels:sub(i,i+15) -- grabs next 16 bytes (so 4 pixels)
    table.insert(self.palette_array, {
          {pixel_bytes:sub(1,1):byte(), pixel_bytes:sub(2,2):byte(), pixel_bytes:sub(3,3):byte(), pixel_bytes:sub(4,4):byte()},
          {pixel_bytes:sub(5,5):byte(), pixel_bytes:sub(6,6):byte(), pixel_bytes:sub(7,7):byte(), pixel_bytes:sub(8,8):byte()},
          {pixel_bytes:sub(9,9):byte(), pixel_bytes:sub(10,10):byte(), pixel_bytes:sub(11,11):byte(), pixel_bytes:sub(12,12):byte()},
          {pixel_bytes:sub(13,13):byte(), pixel_bytes:sub(14,14):byte(), pixel_bytes:sub(15,15):byte(), pixel_bytes:sub(16,16):byte()}
    })
  end
  --

-- PALETTES (main source: https://lospec.com/palette-list/tag/gameboy/)

-- Default palette (Created by VinnyVideo)
-- Links Awakening (SGB) Palette (A palette used by The Legend of Zelda: Link's Awakening DX when played on the Super Gameboy.)
-- Fantasy 16px - Tileset (From a tileset on OGA by Jerom)
-- Kid Icarus (SGB) Palette (A palette used by Kid Icarus: Of Myths and Monsters when played on the Super Gameboy.)
-- Crimson (Created by WildLeoKnight)
-- SpaceHaze (Created by WildLeoKnight)
-- Fantasy 16px - Mockup (From a tileset and a mockup on OGA by Jerom)

-- Blue Seni (Created by WildLeoKnight)
-- Mist GB (Created by Kerrie Lake)

-- 
-- AYY4 (Created by Polyducks)
-- Ice Cream GB (Created by Kerrie Lake)
-- Kirokaze Gameboy (Created by Kirokaze)
-- Rustic GB (Created by Kerrie Lake)
-- Wish GB (Created by Kerrie Lake)
-- Nymph GB (Created by Kerrie Lake)

-- Andrade Gameboy (Alternative Gameboy palette by Andrade)                


-- Coldfire GB (Created by Kerrie Lake)

-- Fantasy 16px - OFMG (From a tileset and a mockup on OGA by Jerom)

-- Nostalgia (Created by WildLeoKnight)

  self.palette_name = { "000 - Default palette", 
                        "001 - Links Awakening (SGB)",
                        "002 - Fantasy 16px - Tileset",
                        "003 - Kid Icarus (SGB)",
                        "004 - Crimson",
                        "005 - SpaceHaze",
                        "006 - Fantasy 16px - Mockup",
                        "007 - ",
                        "008 - Blue Seni",
                        "009 - Mist GB",
                        "010 - ",
                        "011 - AYY4",
                        "012 - Ice Cream GB",
                        "013 - Kirokaze Gameboy",
                        "014 - ",
                        "015 - Wish GB",
                        "016 - Nymph GB",
                        "017 - ",
                        "018 - Andrade Gameboy",
                        "019 ",
                        "020 - Coldfire GB",
                        "021 - ",
                        "022 - Fantasy 16px - OFMG",
                        "023 - ",
                        "024 - Nostalgia",
                        "025 - ",
                        "026 - ",
                        "027 -",
                        "028 - ",
                        "029 - ",
                        "030 - ",
                        "031 - "
}

  self.surface_w, self.surface_h = sol.video.get_quest_size()

  self.pixel = tonumber(info_manager:get_value_in_file("palette.dat", "palette_id"))
  self.active_pixel = self.pixel
  self.palette_k = ring_next(0, self.palette_h, self.pixel, false)
  self.active_palette_k = self.palette_k

  self.inactive_tab_sprite = sol.sprite.create("menus/menu_tabs")
  self.inactive_tab_sprite:set_animation("inactive")
  index_palette_shader:set_palette(self.inactive_tab_sprite)

  self.active_tab_sprite = sol.sprite.create("menus/menu_tabs")
  self.active_tab_sprite:set_animation("active")
  index_palette_shader:set_palette(self.active_tab_sprite)

  --self.bg_surface = sol.surface.create(self.surface_w, self.surface_h)
  --self.bg_surface:fill_color(self.palette_array[self.active_palette_k][1])

  --self.bg2_surface = sol.surface.create(self.surface_w - 16, self.surface_h - 24)
  --self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 0, self.surface_w - 16, 32)
  --self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 134, self.surface_w - 16, 2)
  --self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 82, 32, 2, 102)

  self.preview_w = 128
  self.preview_h = 88
  self.preview_surface = sol.surface.create(self.preview_w, self.preview_h)
  self.preview_surface:fill_color(self.palette_array[self.active_palette_k][2])


  local map = sol.main.get_game():get_map()
  local hero = map:get_hero()
  local hero_x, hero_y = hero:get_position()
  local camera = map:get_camera()
  --local map_w, map_h = map:get_size()
  local camera_x, camera_y = camera:get_position_to_track(hero)
  print("PALETTE MENU", "camera_x:", camera_x, "camera_y:", camera_y )
  if hero_x - (self.preview_w / 2) < camera_x then
    print("X1")
    self.preview_x = 0
  elseif hero_x + (self.preview_w / 2) > camera_x + submenu.camera_w then
    print("X2")
    self.preview_x = submenu.camera_w - self.preview_w
  else
    print("X3")
    self.preview_x =  (hero_x % submenu.camera_w) - (self.preview_w / 2)
  end
  if hero_y - (self.preview_h / 2) < camera_y then
    print("Y1")
    self.preview_y = 0
  elseif hero_y + (self.preview_h / 2) > camera_y + submenu.camera_h then
    print("Y2")
    self.preview_y = submenu.camera_h - self.preview_h
  else
    print("Y3")
    self.preview_y = (hero_y % submenu.camera_h) - (self.preview_h / 2)
  end
  self.camera_surface = camera:get_surface()
  --self.camera_surface:set_scale(2, 2)
  index_palette_shader:set_palette(self.camera_surface)


  self:set_title(sol.language.get_string("palette.title"))
  index_palette_shader:set_palette(submenu.title_surface)

  local w, h = 198, 24
  self.info_surface = sol.surface.create(w, h)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][1])
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][2], 3, 0, w - 6, h)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][2], 1, 1, w - 2, h - 2)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][2], 0, 2, w, h - 4)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][1], 2, 2, w - 4, h - 4)
  self.info_surface:fill_color({0, 0, 0, 255}, 3, 3, w - 6, h - 6) --black



  self.text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "enter_command",
    color = self.palette_array[self.active_palette_k][2],
    text = "PALETTE",
    font_size = 16,
  })
  self.text_surface:set_xy(0, 6)
  self.text_width, self.text_height = self.text_surface:get_size()
  self.title_surface = sol.surface.create(self.text_width, self.text_height)
  self.text_position_x = (self.surface_w - self.text_width) / 2

  self.palette_surface =  sol.surface.create(96, 102)
  self.palette_surface:fill_color(self.palette_array[self.active_palette_k][2])
  self.palette_surface:fill_color(self.palette_array[self.active_palette_k][1], 24, 2, 70, 98)

  self.arrow_sprite1 = sol.sprite.create("menus/pause/arrow_"  .. submenu.test)
  self.arrow_sprite1:set_direction(1)
  self.arrow_sprite1:set_animation("dynamic")
  index_palette_shader:set_palette(self.arrow_sprite1)

  self.arrow_sprite2 = sol.sprite.create("menus/pause/arrow_" .. submenu.test)
  self.arrow_sprite2:set_direction(3)
  self.arrow_sprite2:set_animation("dynamic")
  index_palette_shader:set_palette(self.arrow_sprite2)

  self.id_surface = sol.surface.create(24, 102)
  self.id_text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "enter_command",
    font_size = 16,
  })
  self.id_text_surface:set_color(self.palette_array[self.active_palette_k][1])

  self.id_name_surface = sol.surface.create(200, 16)
  self.id_name_text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "enter_command",
    font_size = 16,
  })

end


function palette_menu:on_draw(dst_surface)


  self:draw_background(dst_surface, true)

	--self.bg_surface:draw(dst_surface, 0, 0)



  self.preview_surface:draw(dst_surface, 181, 69)
  self.camera_surface:draw_region(self.preview_x, self.preview_y, self.preview_w , self.preview_h, self.preview_surface, 0, 0) --OFFSET A SUPPRIMER?

  for i=1, 6 do
    if i == 1 then
      self.tab_x = 24
    else
      self.tab_x = self.tab_x + 32
    end
    if i == self.tab then
      --self.active_tab_sprite:draw(dst_surface, self.tab_x, 16)
    else
      --self.inactive_tab_sprite:draw(dst_surface, self.tab_x, 16)
    end
  end


  --local borders_x = 16
  --local borders_y = 24

  local w, h = self.info_surface:get_size()
  self.info_surface:draw(dst_surface, (submenu.dst_w - w) / 2, 174)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][1])
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][2], 3, 0, w - 6, h)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][2], 1, 1, w - 2, h - 2)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][2], 0, 2, w, h - 4)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][1], 2, 2, w - 4, h - 4)
  self.info_surface:fill_color({0, 0, 0, 255}, 3, 3, w - 6, h - 6) --black
  local o = 5 --offset
  local w, h = (w - (o * 2)) / 4, h - (o * 2)
  for i=0, 3 do
    self.info_surface:fill_color(self.palette_array[self.palette_k][i + 1], (w * i) + o, o, w, h)
  end


  self.palette_surface:draw(dst_surface, 65, 67)
  submenu.img:draw_region(24, 20, 24, 12, dst_surface, 65, 55)
  submenu.img:draw_region(20, 16, 4, 4, dst_surface, 157, 67)
  submenu.img:draw_region(20, 20, 4, 4, dst_surface, 157, 165)
  submenu.img:draw_region(16, 28, 4, 4, dst_surface, 65, 165)

  self.arrow_sprite1:draw(dst_surface, 124, 66)
  self.arrow_sprite2:draw(dst_surface, 124, 170)

  self.offset_y = 5
  self.id_surface:draw(dst_surface, 68, 70)
  self.id_name_surface:draw(dst_surface, 96, 176)
  if self.palette_k < 8 then
     self.k = 32
  else
    self.k = math.floor(self.palette_k / 8) * 8
  end
  if self.k % 8 == 0 then
    self.id_surface:clear()
  end 
  for i=1, 8 do
    self.id_text_surface:set_text(string.sub(self.palette_name[self.k], 0, 3))
    self.id_text_surface:set_xy(1, self.offset_y)
    self.id_text_surface:set_color(self.palette_array[self.active_palette_k][1])
    if self.k == self.palette_k then
      self.palette_surface:fill_color({255, 255, 255, 255}, 25, self.offset_y - 2, 68, 12)
      self.palette_surface:fill_color({0, 0, 0, 255}, 26, self.offset_y - 1, 66, 10)
      self.id_text_surface:set_color(self.palette_array[self.active_palette_k][4])
      text_fx_helper:draw_text(self.id_surface, self.id_text_surface)
    else
      self.palette_surface:fill_color({0, 0, 0, 255}, 25, self.offset_y - 2, 68, 12)
      text_fx_helper:draw_text(self.id_surface, self.id_text_surface)
      if self.k == self.active_palette_k then
        self.palette_surface:fill_color({255, 255, 255, 255}, 25, self.offset_y - 2, 68, 12)
        text_fx_helper:draw_text_with_stroke(self.id_surface, self.id_text_surface, self.palette_array[self.active_palette_k][4])
      end
    end
    self.palette_surface:fill_color(self.palette_array[self.k][1], 27, self.offset_y, 16, 8)
    self.palette_surface:fill_color(self.palette_array[self.k][2], 43, self.offset_y, 16, 8)
    self.palette_surface:fill_color(self.palette_array[self.k][3], 59, self.offset_y, 16, 8)
    self.palette_surface:fill_color(self.palette_array[self.k][4], 75, self.offset_y, 16, 8)

    self.k = ring_next(1, self.palette_h, self.k, false)
    self.offset_y = self.offset_y + 12
  end
  --self.id_name_surface:fill_color({255, 0, 255, 255})

  self.id_name_surface:clear()
  self.stroke_color = self.palette_array[self.palette_k][1]
  self.id_name_text_surface:set_color(self.palette_array[self.palette_k][4])
  self.id_name_text_surface:set_text(self.palette_name[self.palette_k])
  self.id_name_text_width, self.id_text_height = self.id_name_text_surface:get_size()
  self.id_name_text_surface:set_xy((200 - self.id_name_text_width) / 2, 8)
  text_fx_helper:draw_text_with_stroke(self.id_name_surface, self.id_name_text_surface, self.stroke_color)

end


function palette_menu:on_key_pressed(key)

  --local handled = false
  local one_shift = 1 / self.palette_h
  if key == "down" then
    self.pixel = ring_next(0, self.palette_h - 1, self.pixel, false)
    self.palette_k  = ring_next(1, self.palette_h, self.palette_k, false)
  elseif key == "up" then
    self.pixel = ring_next(0, self.palette_h - 1, self.pixel, true)
    self.palette_k = ring_next(1, self.palette_h, self.palette_k, true)
  elseif key == "left" then
    self:previous_submenu()
  elseif key == "space" or key == "return" then
     local shift = one_shift * self.pixel
     self.active_pixel = self.pixel
     self.active_palette_k = self.palette_k

     info_manager:set_value_in_file("palette.dat", "palette_id", self.pixel)
     info_manager:set_value_in_file("palette.dat", "shift", shift)

     --self.bg_surface:fill_color(self.palette_array[self.active_palette_k][1])

     --self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 0, self.surface_w - 16, 32)
     --self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 134, self.surface_w - 16, 2)
     --self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 82, 32, 2, 102)

     --self.preview_surface:fill_color(self.palette_array[self.active_palette_k][2])
     --self.preview_surface:fill_color(self.palette_array[self.active_palette_k][1], 1, 1, 98, 102)
     --self.preview_surface:fill_color({0, 0, 0, 255}, 3, 3, 94, 96)
     --self.preview_surface:fill_color(self.palette_array[self.active_palette_k][4], 1, 101, 98, 1)


     --index_palette_shader:set_palette(self.inactive_tab_sprite)
     --index_palette_shader:set_palette(self.active_tab_sprite)
     index_palette_shader:set_palette(submenu.title_surface)
     index_palette_shader:set_palette(self.camera_surface)
     self.palette_surface =  sol.surface.create(96, 102)
     self.palette_surface:fill_color(self.palette_array[self.active_palette_k][2])
     self.palette_surface:fill_color(self.palette_array[self.active_palette_k][1], 24, 2, 70, 98)

     self.id_text_surface:set_color(self.palette_array[self.active_palette_k][1])

     index_palette_shader:set_palette(self.arrow_sprite1)
     index_palette_shader:set_palette(self.arrow_sprite2)

     index_palette_shader:set_palette(submenu.surface)
     index_palette_shader:set_palette(submenu.img)

     self.text_surface:set_color(self.palette_array[self.active_palette_k][2])

  end
  --return handled
end


function palette_menu:on_finished()

  --local camera = sol.main.get_game():get_map():get_camera()
  --self.camera_surface = camera:get_surface()
  --self.camera_surface:clear()
  --index_palette_shader:set_palette(self.camera_surface)
  --sol.video.set_shader(nil)
  index_palette_shader:set_palette()
end


return palette_menu
