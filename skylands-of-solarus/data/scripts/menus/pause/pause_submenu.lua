-- Base class of each submenu.

local submenu = {}

local language_manager = require("scripts/language_manager")
local messagebox = require("scripts/menus/messagebox")
local text_fx_helper = require("scripts/text_fx_helper")

local submenus_icon_bg_sprites = {"submenu.submenus_icon_bg_sprite1", "submenu.submenus_icon_bg_sprite2"}
local submenus_icon_bg_animations = {"activated", "inactivated"}

function submenu:new(game)
  local o = { game = game }
  setmetatable(o, self)
  self.__index = self
  return o
end

function submenu:on_started()

  submenu.colors = {{15, 31, 31}, {48, 111, 80}, {143, 192, 112}, {224, 255, 208}}
  submenu.theme_colors = {
    {submenu.colors[1] , submenu.colors[2], submenu.colors[3], submenu.colors[4]},
    {submenu.colors[2] , submenu.colors[1], submenu.colors[3], submenu.colors[4]},
    {submenu.colors[3] , submenu.colors[4], submenu.colors[3], submenu.colors[4]},
    {submenu.colors[4] , submenu.colors[3], submenu.colors[2], submenu.colors[1]}
  }
  submenu.theme = self.game:get_value("submenu_theme") or 1
  submenu.test = 1
  submenu.sprite = self.game:get_value("submenu_bg_icon_sprite") or 1
  -- submenu.dst_x, submenu.dst_y = config.x, config.y
  submenu.dst_x, submenu.dst_y = 0, 0
  submenu.dst_w, submenu.dst_h = sol.video.get_quest_size()
  submenu.camera_w, submenu.camera_h = sol.main.get_game():get_map():get_camera():get_size()
  print("PAUSE SUBMENU", "submenu.camera_w: ", submenu.camera_w, "submenu.camera_h: ", submenu.camera_h)
  submenu.left_w = (submenu.dst_w - submenu.camera_w) / 2
  -- Creation of surfaces
  submenu.img = sol.surface.create("menus/pause/menu_" .. submenu.theme .. ".png")
  submenu.surface = sol.surface.create(submenu.dst_w, submenu.dst_h)


  submenus_icon_bg_sprites[1] = sol.sprite.create("menus/pause/submenus_icon_bg_" .. submenu.theme)
  submenus_icon_bg_sprites[1]:set_animation(submenus_icon_bg_animations[1])
  submenus_icon_bg_sprites[2] = sol.sprite.create("menus/pause/submenus_icon_bg_" .. submenu.theme)
  submenus_icon_bg_sprites[2]:set_animation(submenus_icon_bg_animations[2])
  submenu.inventory_icon = sol.surface.create("menus/pause/inventory_icon_" .. submenu.test .. ".png")
  submenu.emoji_icon = sol.surface.create("menus/pause/emoji_icon_".. submenu.test .. ".png")

  -- Fix the font shift (issue with some fonts)
  self.font_y_shift = 0
  
  -- State.
  self.save_messagebox_opened = false
  
  -- Load images.
  -- self.background_surfaces = sol.surface.create("menus/pause/submenus.png")
  -- local img_width, img_height = self.background_surfaces:get_size()
  -- self.width, self.height = img_width / 4, img_height
  --self.width, self.height = sol.video.get_quest_size() -- A remplacer par submenu.dst_w et submenu.dst_h
  submenu.title_arrows = sol.surface.create("menus/pause/submenus_arrows.png")
  self.caption_background = sol.surface.create("menus/pause/submenus_caption.png") 
  self.caption_background_w, self.caption_background_h = self.caption_background:get_size()
   
  -- Create captions.
  local menu_font, menu_font_size = language_manager:get_menu_font()
  self.font_size = menu_font_size
  self.text_color = { 115, 59, 22 }
  self.caption_text_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    color = self.text_color,
  }
  self.caption_text_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    color = self.text_color,
  }

  -- Create title.
  submenu.title = ""
  submenu.title_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    color = submenu.theme_colors[submenu.theme][3],
  }
  submenu.title_surface = sol.surface.create(128, 20)

  -- Command icons.
  self.game:set_custom_command_effect("action", nil)
  self.game:set_custom_command_effect("attack", nil) -- old value "save"

  -- Register if a dialog or messagebox is opened.
  self.backup_dialog_opened = false
  self.dialog_opened = false
end

function submenu:show_info_dialog(dialog_id, callback)
  if not self.dialog_opened then
    self.backup_dialog_opened = self.dialog_opened
    self.dialog_opened = true
    self.game:start_dialog(dialog_id, function()
      self.dialog_opened = self.backup_dialog_opened
      self.backup_dialog_opened = false
      if callback then
        callback()
      end
    end)
  end
end

-- Sets the caption text key.
function submenu:set_caption_key(text_key)
  if text_key == nil then
    self:set_caption(nil)
  else
    local text = sol.language.get_string(text_key)
    self:set_caption(text)
  end
end

-- Sets the caption text.
-- The caption text can have one or two lines, with 20 characters maximum for each line.
-- If the text you want to display has two lines, use the '$' character to separate them.
-- A value of nil removes the previous caption if any.
function submenu:set_caption(text)
  if text == nil then
    self.caption_text_1:set_text(nil)
    self.caption_text_2:set_text(nil)
  else
    local line1, line2 = text:match("([^$]+)%$(.*)")
    if line1 == nil then
      -- Only one line.
      self.caption_text_1:set_text(text)
      self.caption_text_2:set_text(nil)
    else
      -- Two lines.
      self.caption_text_1:set_text(line1)
      self.caption_text_2:set_text(line2)
    end 
  end
end

-- Draw the caption text previously set.
function submenu:draw_caption(dst_surface)
  -- Draw only if save dialog is not displayed.
  if not self.dialog_opened then
    local width, height = dst_surface:get_size()
    local center_x, center_y = width / 2, height / 2

    -- Draw caption frame.
    -- local caption_x, caption_y = center_x - self.caption_background_w / 2, center_y + self.height / 2 - self.caption_background_h
    local caption_x = center_x - self.caption_background_w / 2
    local caption_y = height - self.caption_background_h - 16 
    -- caption_y = math.min(caption_y, height - 8 - self.caption_background_h)
    self.caption_background:draw(dst_surface, caption_x, caption_y)
    local caption_center_y = caption_y + self.caption_background_h / 2

    -- Draw caption text.
    if self.caption_text_2:get_text():len() == 0 then
      -- If only one line, center vertically the only line.
      self.caption_text_1:draw(dst_surface, center_x, caption_center_y - 2 + self.font_y_shift)
    else
      -- If two lines.
      local line_spacing = self.font_size / 2 + 2
      self.caption_text_1:draw(dst_surface, center_x, caption_center_y - self.font_size)
      self.caption_text_2:draw(dst_surface, center_x, caption_center_y + line_spacing)
    end
  end
end

-- Goes to the next pause screen.
function submenu:next_submenu()
  sol.audio.play_sound("menus/pause_menu_close")
  sol.menu.stop(self)
  local submenus = self.game.pause_submenus
  local submenu_index = self.game:get_value("pause_last_submenu")
  submenu_index = (submenu_index % #submenus) + 1
  self.game:set_value("pause_last_submenu", submenu_index)
  sol.menu.start(self.game.pause_menu, submenus[submenu_index], false)
end

-- Goes to the previous pause screen.
function submenu:previous_submenu()
  sol.audio.play_sound("menus/pause_menu_close")
  sol.menu.stop(self)
  local submenus = self.game.pause_submenus
  local submenu_index = self.game:get_value("pause_last_submenu")
  submenu_index = (submenu_index - 2) % #submenus + 1
  self.game:set_value("pause_last_submenu", submenu_index)
  sol.menu.start(self.game.pause_menu, submenus[submenu_index], false)
end

-- Shows the messagebox to save the game.
function submenu:show_save_messagebox()
  self.backup_dialog_opened = self.dialog_opened
  self.dialog_opened = true

  messagebox:show(self, 
    -- Text lines.
    {
     sol.language.get_string("save_dialog.save_question_0"),
     sol.language.get_string("save_dialog.save_question_1"),
    },
    -- Buttons
    sol.language.get_string("messagebox.yes"),
    sol.language.get_string("messagebox.no"),
    -- Default button
    1,
    -- Callback called after the user has chosen an answer.
    function(result)
      self.dialog_opened = self.backup_dialog_opened
      self.backup_dialog_opened = false

      if result == 1 then
        self.game:save()
      end
    
      -- Ask the user if he/she wants to continue the game.
      self:show_continue_messagebox()
  end)
end

-- Show the messagebox to ask the user if he/she wants to continue.
function submenu:show_continue_messagebox()
  self.backup_dialog_opened = self.dialog_opened
  self.dialog_opened = true

  messagebox:show(self, 
    -- Text lines.
    {
     sol.language.get_string("save_dialog.continue_question_0"),
     sol.language.get_string("save_dialog.continue_question_1"),
    },
    -- Buttons
    sol.language.get_string("messagebox.yes"),
    sol.language.get_string("messagebox.no"),
    -- Default button
    1,
    -- Callback called after the user has chosen an answer.
    function(result)
      self.dialog_opened = self.backup_dialog_opened
      self.backup_dialog_opened = false

      if result == 2 then
        sol.main.reset()
      end
  end) 
end

-- Commands to navigate in the pause menu. 
function submenu:on_command_pressed(command)
  local handled = false

  if self.game:is_dialog_enabled() or self.dialog_opened then
    -- Commands will be applied to the dialog box only.
    handled = false
  --elseif command == "attack" and not self.dialog_opened then
  --  self:show_save_messagebox()
  --  handled = true
  end

  return handled
end

-- Return the sprite
function submenu:get_icon_bg_sprite(sprite)

  return submenus_icon_bg_sprites[sprite]
end

-- Draw the background
function submenu:draw_background(dst_surface, on_camera)

  local width, height = dst_surface:get_size()
  local center_x = width / 2
  local center_y = height / 2
  local menu_x, menu_y = center_x - width / 2, center_y - height / 2

  -- Draw the menu GUI window &ns the title (in the correct language)
  -- local submenu_index = self.game:get_value("pause_last_submenu")
  local submenu_index = sol.main.get_game():get_value("pause_last_submenu")
  --print("PAUSE SUBMENU" , "submenu_index: ", submenu_index)
  local x1 = 8
  local x2 = 328

  submenu.surface:draw_region(0, 0, 64, 200, dst_surface, 0, 8)  -- Left
  submenu.surface:draw_region(0, 0, 64, 200, dst_surface, 320, 8)   -- Right
  submenu.surface:fill_color(submenu.theme_colors[submenu.theme][1])
  if on_camera then
    -- Fill the camera surface with a colored surface.
     submenu.surface:draw_region(0 , 0, submenu.camera_w + 16, submenu.camera_h, dst_surface, 64, 40)
  else
    -- Inventory icons
    submenus_icon_bg_sprites[1]:draw(dst_surface, 35, 24)
    submenus_icon_bg_sprites[2]:draw(dst_surface, 349, 24)
    submenu.inventory_icon:draw(dst_surface, 23, 13)
    submenu.emoji_icon:draw(dst_surface, 337, 13)
  end
  submenu.img:draw_region(48, 0, 8, 8, dst_surface, 0, 0)
  submenu.img:draw_region(56, 0, 8, 8, dst_surface, 56, 0)
  submenu.img:draw_region(64, 0, 8, 8, dst_surface, 320, 0)
  submenu.img:draw_region(72, 0, 8, 8, dst_surface, 376, 0)
  while x1 < 56 do
    submenu.img:draw_region(0, 0, 8, 8, dst_surface, x1, 0)
    submenu.img:draw_region(8, 8, 8, 8, dst_surface, x1, 208)
    x1 = x1 + 8
  end
  while x2 < 376 do
    submenu.img:draw_region(0, 0, 8, 8, dst_surface, x2, 0)
    submenu.img:draw_region(8, 8, 8, 8, dst_surface, x2, 208)
    x2 = x2 + 8
  end
  submenu.img:draw_region(48, 8, 8, 8, dst_surface, 0, 208)
  submenu.img:draw_region(56, 8, 8, 8, dst_surface, 56, 208)
  submenu.img:draw_region(64, 8, 8, 8, dst_surface, 320, 208)
  submenu.img:draw_region(72, 8, 8, 8, dst_surface, 376, 208)


  -- Title
  local title_w, title_h = submenu.title_surface:get_size()
  local title_x, title_y = center_x - title_w / 2, menu_y + 38
  submenu.title_surface:draw(dst_surface, title_x, title_y)

  -- Draw only if save dialog is not displayed.
  if not self.dialog_opened then
    -- Draw arrows on both sides of the menu title
    local title_arrow_w, title_arrow_h = submenu.title_arrows:get_size()
    title_arrow_w = title_arrow_w / 2
    local arrow_spacing = 14
    local arrow_y_shift =  2
    -- Left arrow
    submenu.title_arrows:draw_region(
      0, 0,
      title_arrow_w, title_arrow_h,
      dst_surface,
      title_x - title_arrow_w - arrow_spacing, title_y + arrow_y_shift
    )
    -- Right arrow
    submenu.title_arrows:draw_region(
      title_arrow_w, 0,
      title_arrow_w, title_arrow_h,
      dst_surface,
      title_x + title_w + arrow_spacing, title_y + arrow_y_shift)
  end
end



function submenu:set_bg_icon(sprite, animation)

  if animation == nil or animation == "" then
    animation = "transition"
    submenus_icon_bg_animations[sprite] = "transition"
  end
  if animation ~= submenus_icon_bg_animations[sprite] then
    if animation == "appearing1" then
      submenus_icon_bg_animations[sprite] = "selected"
      submenus_icon_bg_sprites[sprite]:set_animation("appearing1", function()
        submenus_icon_bg_sprites[sprite]:set_animation(submenus_icon_bg_animations[sprite])
      end)
    elseif animation == "disappearing1" then
      submenus_icon_bg_animations[sprite] = "activated"
      submenus_icon_bg_sprites[sprite]:set_animation("disappearing1", function()
        submenus_icon_bg_sprites[sprite]:set_animation(submenus_icon_bg_animations[sprite])
      end)
    elseif animation == "appearing2" then
      submenus_icon_bg_animations[sprite] = "selected"
      submenus_icon_bg_sprites[sprite]:set_animation("appearing2", function()
        submenus_icon_bg_sprites[sprite]:set_animation(submenus_icon_bg_animations[sprite])
      end)
    elseif animation == "disappearing2" then
      submenus_icon_bg_animations[sprite] = "inactivated"
      submenus_icon_bg_sprites[sprite]:set_animation("disappearing2", function()
        submenus_icon_bg_sprites[sprite]:set_animation(submenus_icon_bg_animations[sprite])
      end)
    elseif animation == "dynamic" then
      submenus_icon_bg_animations[sprite] = "dynamic"
      submenus_icon_bg_sprites[sprite]:set_animation("disappearing1", function()
        submenus_icon_bg_sprites[sprite]:set_animation(submenus_icon_bg_animations[sprite])
      end)
    else
      submenus_icon_bg_animations[sprite] = animation
      submenus_icon_bg_sprites[sprite]:set_animation(submenus_icon_bg_animations[sprite])
    end
  end
end

function submenu:set_title(text)
  if text ~= submenu.title then
    submenu.title = text
    self:rebuild_title_surface()
  end
end

function submenu:rebuild_title_surface()
  submenu.title_surface:clear()
  local w, h = submenu.title_surface:get_size()
  submenu.title_surface:fill_color(submenu.theme_colors[submenu.theme][1])
  submenu.title_surface:fill_color(submenu.theme_colors[submenu.theme][2], 1, 2, w - 2, h - 5)
  submenu.title_surface:fill_color(submenu.theme_colors[submenu.theme][2], 2, 1, w - 4, h - 3)
  submenu.title_surface:fill_color(submenu.theme_colors[submenu.theme][2], 4, 0, w - 8, h - 1)
  submenu.title_surface:fill_color(submenu.theme_colors[submenu.theme][2], 0, 0, 1, 1)
  submenu.title_surface:fill_color(submenu.theme_colors[submenu.theme][2], w - 1, 0, 1, 1)
  submenu.title_text:set_text(submenu.title)
  submenu.title_text:set_xy(w / 2, h / 2 - 1)
  text_fx_helper:draw_text_with_stroke(submenu.title_surface, submenu.title_text, submenu.theme_colors[submenu.theme][1])
end

-- Return the menu.
return submenu
