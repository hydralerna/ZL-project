-- Base class of each submenu.

local submenu = {}

local language_manager = require("scripts/language_manager")
--local messagebox = require("scripts/menus/messagebox")
local text_fx_helper = require("scripts/text_fx_helper")
local audio_manager = require("scripts/audio_manager")

function submenu:new(game)
  local o = { game = game }
  setmetatable(o, self)
  self.__index = self
  return o
end

function submenu:on_started()
  -- Fix the font shift (issue with some fonts)
  self.font_y_shift = 0
  
  -- State.
  self.save_messagebox_opened = false
  
  -- Load images.
  -- self.background_surfaces = sol.surface.create("menus/pause/submenus.png")
  -- local img_width, img_height = self.background_surfaces:get_size()
  -- self.width, self.height = img_width / 4, img_height
  self.width, self.height = sol.video.get_quest_size()
  self.title_arrows = sol.surface.create("menus/pause/submenus_arrows.png")
  self.caption_background = sol.surface.create("menus/pause/submenus_caption.png") 
  self.caption_background_w, self.caption_background_h = self.caption_background:get_size()
  
  -- Dark surface whose goal is to slightly hide the game and better highlight the menu.
  local quest_w, quest_h = sol.video.get_quest_size()
  self.dark_surface = sol.surface.create(quest_w, quest_h)
  self.dark_surface:fill_color({112, 112, 112})
  self.dark_surface:set_blend_mode("multiply")
  
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
  self.title = ""
  self.title_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    color = {255, 255, 255},
  }
  self.title_stroke_color = {158, 117, 70}
  self.title_shadow_color = {85, 20, 0}
  self.title_surface = sol.surface.create(88, 16)

  -- Command icons.
  self.game:set_custom_command_effect("action", nil)
  self.game:set_custom_command_effect("attack", "save")

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
    local caption_x, caption_y = center_x - self.caption_background_w / 2, center_y + self.height / 2 - self.caption_background_h
    caption_y = math.min(caption_y, height - 8 - self.caption_background_h)
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
  audio_manager:play_sound("menus/pause_menu_close")
  sol.menu.stop(self)
  local submenus = self.game.pause_submenus
  local submenu_index = self.game:get_value("pause_last_submenu")
  submenu_index = (submenu_index % #submenus) + 1
  self.game:set_value("pause_last_submenu", submenu_index)
  sol.menu.start(self.game.pause_menu, submenus[submenu_index], false)
end

-- Goes to the previous pause screen.
function submenu:previous_submenu()
  audio_manager:play_sound("menus/pause_menu_close")
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
  elseif command == "attack" and not self.dialog_opened then
    self:show_save_messagebox()
    handled = true
  end

  return handled
end

function submenu:draw_background(dst_surface)
  local width, height = dst_surface:get_size()
  local center_x = width / 2
  local center_y = height / 2
  local menu_x, menu_y = center_x - self.width / 2, center_y - self.height / 2

  -- Fill the screen with a dark surface.
  self.dark_surface:draw(dst_surface)

  -- Draw the menu GUI window &ns the title (in the correct language)
  local submenu_index = self.game:get_value("pause_last_submenu")
  --self.background_surfaces:draw_region(
  --    self.width * (submenu_index - 1), 0,  -- region x, y
  --    self.width, self.height,              -- region w, h
  --    dst_surface,                          -- destination surface
  --    menu_x, menu_y                        -- x, y in destination surface
  --d)
  local title_w, title_h = self.title_surface:get_size()
  local title_x, title_y = center_x - title_w / 2, menu_y + 32
  self.title_surface:draw(dst_surface, title_x, title_y)

  -- Draw only if save dialog is not displayed.
  if not self.dialog_opened then
    -- Draw arrows on both sides of the menu title
    local title_arrow_w, title_arrow_h = self.title_arrows:get_size()
    title_arrow_w = title_arrow_w / 2
    local arrow_spacing = 14
    local arrow_y_shift =  2
    -- Left arrow
    self.title_arrows:draw_region(
      0, 0,
      title_arrow_w, title_arrow_h,
      dst_surface,
      title_x - title_arrow_w - arrow_spacing, title_y + arrow_y_shift
    )
    -- Right arrow
    self.title_arrows:draw_region(
      title_arrow_w, 0,
      title_arrow_w, title_arrow_h,
      dst_surface,
      title_x + title_w + arrow_spacing, title_y + arrow_y_shift)
  end
end

function submenu:set_title(text)
  if text ~= self.title then
    self.title = text
    self:rebuild_title_surface()
  end
end

function submenu:rebuild_title_surface()
  self.title_surface:clear()
  local w, h = self.title_surface:get_size()
  self.title_text:set_text(self.title)
  self.title_text:set_xy(w / 2, h / 2 - 2)
  text_fx_helper:draw_text_with_stroke_and_shadow(self.title_surface, self.title_text, self.title_stroke_color, self.title_shadow_color)
end

-- Return the menu.
return submenu
