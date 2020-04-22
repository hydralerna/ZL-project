-- WIP

local game_manager = require("scripts/game_manager")
local index_palette_shader = require("scripts/index_palette_shader")
local info_manager = require("scripts/info_manager")
local text_fx_helper = require("scripts/text_fx_helper")


local palette_menu = {}

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

  self.tab = 2

  self.palette_img = sol.surface.create("shaders/palette.png")
  self.palette_w, self.palette_h = self.palette_img:get_size()

  self.menus_img = sol.surface.create("menus/menus.png")
  index_palette_shader:set_palette(self.menus_img)

  self.menu_tabs_img = sol.surface.create("menus/menu_tabs.png")
  index_palette_shader:set_palette(self.menu_tabs_img)

  -- Create an array containing all the 4-color palettes. From the code by llamazing.
  local pixels = self.palette_img:get_pixels()
  local length = pixels:len() --4 bytes (R, G, B, A) for each pixel
  self.palette_array = {}
  for i=1,length,16 do
    local pixel_bytes = pixels:sub(i,i+15) --grabs next 16 bytes (so 4 pixels)
    table.insert(self.palette_array, {
          {pixel_bytes:sub(1,1):byte(), pixel_bytes:sub(2,2):byte(), pixel_bytes:sub(3,3):byte(), pixel_bytes:sub(4,4):byte()},
          {pixel_bytes:sub(5,5):byte(), pixel_bytes:sub(6,6):byte(), pixel_bytes:sub(7,7):byte(), pixel_bytes:sub(8,8):byte()},
          {pixel_bytes:sub(9,9):byte(), pixel_bytes:sub(10,10):byte(), pixel_bytes:sub(11,11):byte(), pixel_bytes:sub(12,12):byte()},
          {pixel_bytes:sub(13,13):byte(), pixel_bytes:sub(14,14):byte(), pixel_bytes:sub(15,15):byte(), pixel_bytes:sub(16,16):byte()}
    })
  end
  --
  self.palette_name = { "aa00aa", 
                        "aa01aa",
                        "aa02aa",
                        "aa03aa",
                        "aa04aa",
                        "aa05aa",
                        "aa06aa",
                        "aa07aa",
                        "bb08bb",
                        "bb09bb",
                        "bb10bb",
                        "bb11bb",
                        "bb12bb",
                        "bb13bb",
                        "bb14bb",
                        "bb15bb",
                        "cc16cc",
                        "cc17cc",
                        "cc18cc",
                        "cc19cc",
                        "cc20cc",
                        "cc21cc",
                        "cc22cc",
                        "cc23cc",
                        "dd24dd",
                        "dd25dd",
                        "dd26dd",
                        "dd27dd",
                        "dd28dd",
                        "dd29dd",
                        "dd30dd",
                        "dd31dd"
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

  self.bg_surface = sol.surface.create(self.surface_w, self.surface_h)
  self.bg_surface:fill_color(self.palette_array[self.active_palette_k][1])

  self.bg2_surface = sol.surface.create(self.surface_w - 16, self.surface_h - 24)
  self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 0, self.surface_w - 16, 32)
  self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 134, self.surface_w - 16, 2)
  self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 82, 32, 2, 102)

  self.preview_surface = sol.surface.create(100, 102)
  self.preview_surface:fill_color(self.palette_array[self.active_palette_k][2])
  self.preview_surface:fill_color(self.palette_array[self.active_palette_k][1], 1, 1, 98, 102)
  self.preview_surface:fill_color({0, 0, 0, 255}, 3, 3, 94, 96)
  self.preview_surface:fill_color(self.palette_array[self.active_palette_k][4], 1, 101, 98, 1)


  local map = sol.main.get_game():get_map()
  local hero = map:get_hero()
  local hero_x, hero_y = hero:get_position()
  print("hero_x", hero_x, "hero_y", hero_y)
  local camera = map:get_camera()
  local camera_x, camera_y = camera:get_position()
  print("camera_x", camera_x, "camera_y", camera_y)
  self.preview_x = hero_x - camera_x - 45
  self.preview_y = hero_y - camera_y - 46
  print("self.preview_x", self.preview_x, "self.preview_y", self.preview_y)
  self.camera_surface = camera:get_surface()
  --self.camera_surface:set_scale(2, 2)
  index_palette_shader:set_palette(self.camera_surface)




  self.info_surface = sol.surface.create(176, 24)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][2])
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][1], 1, 1, 174, 22)
  self.info_surface:fill_color({0, 0, 0, 255}, 3, 3, 170, 18)
  self.info_surface:fill_color(self.palette_array[self.active_palette_k][4], 0, 23, 176, 1)


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

  self.palette_surface =  sol.surface.create(74, 102)
  self.palette_surface:fill_color(self.palette_array[self.active_palette_k][2])
  self.palette_surface:fill_color(self.palette_array[self.active_palette_k][1], 1, 1, 72, 100)
  self.palette_surface:fill_color(self.palette_array[self.active_palette_k][4], 0, 101, 72, 1)

  self.id_surface = sol.surface.create(168, 16)
  self.id_text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "enter_command",
    font_size = 16,
  })

end


function palette_menu:on_draw(dst_surface)

	self.bg_surface:draw(dst_surface, 0, 0)
 	self.bg2_surface:draw(dst_surface, 8, 16)
  self.preview_surface:draw(dst_surface, 92, 48)
  self.camera_surface:draw_region(self.preview_x, self.preview_y, 90, 92, self.preview_surface, 5, 5)

  for i=1, 6 do
    if i == 1 then
      self.tab_x = 24
    else
      self.tab_x = self.tab_x + 32
    end
    if i == self.tab then
      self.active_tab_sprite:draw(dst_surface, self.tab_x, 16)
    else
      self.inactive_tab_sprite:draw(dst_surface, self.tab_x, 16)
    end
  end

  self.menus_img:draw_region(48, 0, 8, 8, dst_surface, 8, 16)
  self.menus_img:draw_region(56, 0, 8, 8, dst_surface, 192, 16)

  self.menus_img:draw_region(48, 8, 8, 8, dst_surface, 8, 176)
  self.menus_img:draw_region(56, 8, 8, 8, dst_surface, 192, 176)
  local borders_x = 16
  while borders_x  < (self.surface_w - 16) do
   self.menus_img:draw_region(0, 0, 8, 8, dst_surface, borders_x, 16)
   self.menus_img:draw_region(0, 0, 8, 8, dst_surface, borders_x, 40)
   self.menus_img:draw_region(8, 8, 8, 8, dst_surface, borders_x, self.surface_h - 16)
   borders_x = borders_x + 8
  end
  local borders_y = 24
  while borders_y  < (self.surface_h - 16) do
   self.menus_img:draw_region(0, 8, 8, 8, dst_surface, 8, borders_y)
   self.menus_img:draw_region(8, 0, 8, 8, dst_surface, self.surface_w - 16, borders_y)
   borders_y = borders_y + 8
  end
  self.menus_img:draw_region(16, 8, 8, 8, dst_surface, 8, 40)
  self.menus_img:draw_region(24, 0, 8, 8, dst_surface, 192, 40)



  self.info_surface:draw(dst_surface, 16, 152)

  self.info_surface:fill_color(self.palette_array[self.palette_k][1], 6, 5, 41, 14)
  self.info_surface:fill_color(self.palette_array[self.palette_k][2], 47, 5, 41, 14)
  self.info_surface:fill_color(self.palette_array[self.palette_k][3], 88, 5, 41, 14)
  self.info_surface:fill_color(self.palette_array[self.palette_k][4], 129, 5, 41, 14)

  self.title_surface:draw(dst_surface, self.text_position_x, 24)
  self.title_surface:fill_color(self.palette_array[self.active_palette_k][3])
  --self.title_surface:clear()
  text_fx_helper:draw_text(self.title_surface, self.text_surface)



  self.palette_surface:draw(dst_surface, 16, 48)

  self.offset_y = 5
  self.id_surface:draw(dst_surface, 20, 156)
  if self.palette_k < 8 then
     self.k = 32
  else
    self.k = math.floor(self.palette_k / 8) * 8
  end
  for i=1, 8 do
    if self.k == self.palette_k then
      self.palette_surface:fill_color({255, 255, 255, 255}, 3, self.offset_y - 2, 68, 12)
      self.palette_surface:fill_color({0, 0, 0, 255}, 4, self.offset_y - 1, 66, 10)
    else
      self.palette_surface:fill_color({0, 0, 0, 255}, 3, self.offset_y - 2, 68, 12)
      if self.k == self.active_palette_k then
        self.palette_surface:fill_color({255, 255, 255, 255}, 3, self.offset_y - 2, 68, 12)
      end
    end
    self.palette_surface:fill_color(self.palette_array[self.k][1], 5, self.offset_y, 16, 8)
    self.palette_surface:fill_color(self.palette_array[self.k][2], 21, self.offset_y, 16, 8)
    self.palette_surface:fill_color(self.palette_array[self.k][3], 37, self.offset_y, 16, 8)
    self.palette_surface:fill_color(self.palette_array[self.k][4], 53, self.offset_y, 16, 8)
    self.k = ring_next(1, self.palette_h, self.k, false)
    self.offset_y = self.offset_y + 12
  end
  -- self.id_surface:fill_color({255, 0, 255, 255})

  self.id_surface:clear()
  self.stroke_color = self.palette_array[self.palette_k][1]
  self.id_text_surface:set_color(self.palette_array[self.palette_k][4])
  self.id_text_surface:set_text(self.palette_name[self.palette_k])
  self.id_text_width, self.id_text_height = self.id_text_surface:get_size()
  self.id_text_surface:set_xy((168 - self.id_text_width) / 2, 7)
  text_fx_helper:draw_text_with_stroke(self.id_surface, self.id_text_surface, self.stroke_color)

  self.menus_img:draw_region(0, 16, 4, 4, dst_surface, 16, 47)
  self.menus_img:draw_region(4, 16, 4, 4, dst_surface, 86, 47)
  self.menus_img:draw_region(0, 20, 4, 4, dst_surface, 16, 147)
  self.menus_img:draw_region(4, 20, 4, 4, dst_surface, 86, 147)

  self.menus_img:draw_region(0, 16, 4, 4, dst_surface, 92, 47)
  self.menus_img:draw_region(4, 16, 4, 4, dst_surface, 188, 47)
  self.menus_img:draw_region(0, 20, 4, 4, dst_surface, 92, 147)
  self.menus_img:draw_region(4, 20, 4, 4, dst_surface, 188, 147)

  self.menus_img:draw_region(0, 16, 4, 4, dst_surface, 16, 151)
  self.menus_img:draw_region(4, 16, 4, 4, dst_surface, 188, 151)
  self.menus_img:draw_region(0, 20, 4, 4, dst_surface, 16, 173)
  self.menus_img:draw_region(4, 20, 4, 4, dst_surface, 188, 173)

  self.menus_img:draw_region(32, 16, 8, 5, dst_surface, 48, 46)
  self.menus_img:draw_region(40, 16, 8, 5, dst_surface, 48, 147)

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
  elseif key == "space" or key == "return" then
     local shift = one_shift * self.pixel
     self.active_pixel = self.pixel
     self.active_palette_k = self.palette_k

     info_manager:set_value_in_file("palette.dat", "palette_id", self.pixel)
     info_manager:set_value_in_file("palette.dat", "shift", shift)

     self.bg_surface:fill_color(self.palette_array[self.active_palette_k][1])

     self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 0, self.surface_w - 16, 32)
     self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 0, 134, self.surface_w - 16, 2)
     self.bg2_surface:fill_color(self.palette_array[self.active_palette_k][3], 82, 32, 2, 102)

     self.preview_surface:fill_color(self.palette_array[self.active_palette_k][2])
     self.preview_surface:fill_color(self.palette_array[self.active_palette_k][1], 1, 1, 98, 102)
     self.preview_surface:fill_color({0, 0, 0, 255}, 3, 3, 94, 96)
     self.preview_surface:fill_color(self.palette_array[self.active_palette_k][4], 1, 101, 98, 1)


     index_palette_shader:set_palette(self.inactive_tab_sprite)
     index_palette_shader:set_palette(self.active_tab_sprite)
     index_palette_shader:set_palette(self.camera_surface)
     self.palette_surface:fill_color(self.palette_array[self.active_palette_k][2])
     self.palette_surface:fill_color(self.palette_array[self.active_palette_k][1], 1, 1, 72, 100)
     self.palette_surface:fill_color(self.palette_array[self.active_palette_k][4], 0, 101, 72, 1)

     self.info_surface:fill_color(self.palette_array[self.active_palette_k][2])
     self.info_surface:fill_color(self.palette_array[self.active_palette_k][1], 1, 1, 174, 22)
     self.info_surface:fill_color({0, 0, 0, 255}, 3, 3, 170, 18)
     self.info_surface:fill_color(self.palette_array[self.active_palette_k][4], 0, 23, 176, 1)

     index_palette_shader:set_palette(self.menus_img)

     self.text_surface:set_color(self.palette_array[self.active_palette_k][2])

  end
  --return handled
end

return palette_menu
