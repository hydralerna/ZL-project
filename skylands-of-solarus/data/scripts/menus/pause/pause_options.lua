local submenu = require("scripts/menus/pause/pause_submenu")
local language_manager = require("scripts/language_manager")

local options_submenu = submenu:new()

function options_submenu:on_started()

  submenu.on_started(self)
      
  -- Set title
  self:set_title(sol.language.get_string("options.title"))

  local font, font_size = language_manager:get_menu_font()
  local width, height = sol.video.get_quest_size()
  local center_x, center_y = width / 2, height / 2

  self.column_color = { 255, 255, 255}
  self.text_color = { 115, 59, 22 }

  self.video_mode_label_text = sol.text_surface.create{
    horizontal_alignment = "left",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "settings.video_filter",
    color = self.text_color,
  }
  self.video_mode_label_text:set_xy(center_x - 50, center_y -60 + self.font_y_shift)

  self.video_mode_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text = sol.video.get_mode(),
    color = self.text_color,
  }
  self.video_mode_text:set_xy(center_x + 74, center_y - 60 + self.font_y_shift)

  self.command_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.commands_column",
    color = self.column_color,
  }
  self.command_column_text:set_xy(center_x - 76, center_y - 37 + self.font_y_shift)

  self.keyboard_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.keyboard_column",
    color = self.column_color,
  }
  self.keyboard_column_text:set_xy(center_x - 7, center_y - 37 + self.font_y_shift)

  self.joypad_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.joypad_column",
    color = self.column_color,
  }
  self.joypad_column_text:set_xy(center_x + 69, center_y - 37 + self.font_y_shift)

  self.commands_surface = sol.surface.create(215, 160)
  self.commands_surface:set_xy(center_x - 107, center_y - 18)
  self.commands_highest_visible = 1
  self.commands_visible_y = 0

  self.command_texts = {}
  self.keyboard_texts = {}
  self.joypad_texts = {}
  self.command_names = { "action", "attack", "item_1", "item_2", "pause", "left", "right", "up", "down" }
  
  for i = 1, #self.command_names do

    self.command_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      text_key = "options.command." .. self.command_names[i],
      color = self.text_color,
    }

    self.keyboard_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      color = self.text_color,
    }

    self.joypad_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      color = self.text_color,
    }
  end

  self:load_command_texts()

  self.up_arrow_sprite = sol.sprite.create("menus/pause/arrow")
  self.up_arrow_sprite:set_direction(1)
  self.up_arrow_sprite:set_xy(center_x - 64, center_y - 24)
  self.down_arrow_sprite = sol.sprite.create("menus/pause/arrow")
  self.down_arrow_sprite:set_direction(3)
  self.down_arrow_sprite:set_xy(center_x - 64, center_y + 62)
  self.cursor_sprite = sol.sprite.create("menus/pause/options/cursor")
  self.command_cursor_sprite = sol.sprite.create("menus/pause/options/command_cursor")
  self.cursor_position = nil
  self:set_cursor_position(1)
  self.waiting_for_command = false

  self.game:set_custom_command_effect("action", "change")
end

-- Loads the text displayed for each game command, for the
-- keyboard and the joypad.
function options_submenu:load_command_texts()

  self.commands_surface:clear()
  for i = 1, #self.command_names do
    local keyboard_binding = self.game:get_command_keyboard_binding(self.command_names[i])
    local joypad_binding = self.game:get_command_joypad_binding(self.command_names[i])
    self.keyboard_texts[i]:set_text(keyboard_binding:sub(1, 9))
    self.joypad_texts[i]:set_text(joypad_binding:sub(1, 9))

    local y = 16 * i - 14
    self.command_texts[i]:draw(self.commands_surface, 4, y)
    self.keyboard_texts[i]:draw(self.commands_surface, 74, y)
    self.joypad_texts[i]:draw(self.commands_surface, 143, y)
  end
end

function options_submenu:set_cursor_position(position)

  if position ~= self.cursor_position then

    local width, height = sol.video.get_quest_size()

    self.cursor_position = position
    if position == 1 then  -- Video mode.
      self:set_caption_key("options.caption.press_action_change_mode")
      self.cursor_sprite.x = width / 2 + 78
      self.cursor_sprite.y = height / 2 - 51
    else  -- Customization of a command.
      self:set_caption_key("options.caption.press_action_customize_key")

      -- Make sure the selected command is visible.
      while position <= self.commands_highest_visible do
        self.commands_highest_visible = self.commands_highest_visible - 1
        self.commands_visible_y = self.commands_visible_y - 16
      end

      while position > self.commands_highest_visible + 5 do
        self.commands_highest_visible = self.commands_highest_visible + 1
        self.commands_visible_y = self.commands_visible_y + 16
      end

      self.cursor_sprite.x = width / 2 - 71
      self.cursor_sprite.y = height / 2 - 32 + 6 + 16 * (position - self.commands_highest_visible)
    end
  end
end

function options_submenu:on_draw(dst_surface)

  -- Draw background.
  self:draw_background(dst_surface, true)
  
  -- Draw caption.
  self:draw_caption(dst_surface)
  
  -- Text.
  self.video_mode_label_text:draw(dst_surface)
  self.video_mode_text:draw(dst_surface)
  self.command_column_text:draw(dst_surface)
  self.keyboard_column_text:draw(dst_surface)
  self.joypad_column_text:draw(dst_surface)
  self.commands_surface:draw_region(0, self.commands_visible_y, 215, 84, dst_surface)
  
  -- Arrows.
  if self.commands_visible_y > 0 then
    self.up_arrow_sprite:draw(dst_surface)
    self.up_arrow_sprite:draw(dst_surface, 115, 0)
  end
  
  if self.commands_visible_y < 60 then
    self.down_arrow_sprite:draw(dst_surface)
    self.down_arrow_sprite:draw(dst_surface, 115, 0)
  end
  
  -- Draw cursor (only when the save dialog is not open).
  if not self.dialog_opened then
    if self.waiting_for_command then
      -- Cursor when waiting for a command, in both cells (keyboard and joypad).
      self.command_cursor_sprite:draw(dst_surface, self.cursor_sprite.x + 64, self.cursor_sprite.y)
      self.command_cursor_sprite:draw(dst_surface, self.cursor_sprite.x + 138, self.cursor_sprite.y)
    else
      -- Normal cursor.
      self.cursor_sprite:draw(dst_surface, self.cursor_sprite.x, self.cursor_sprite.y)
    end
  end

end

function options_submenu:on_command_pressed(command)

  if self.command_customizing ~= nil then
    -- We are customizing a command: any key pressed should have been handled before.
    error("options_submenu:on_command_pressed() should not called in this state")
  end

  local handled = submenu.on_command_pressed(self, command)

  if not handled then
    if command == "left" then
      self:previous_submenu()
      handled = true
    elseif command == "right" then
      self:next_submenu()
      handled = true
    elseif command == "up" then
      sol.audio.play_sound("menus/menu_cursor")
      self:set_cursor_position((self.cursor_position + 8) % 10 + 1)
      handled = true
    elseif command == "down" then
      sol.audio.play_sound("menus/menu_cursor")
      self:set_cursor_position(self.cursor_position % 10 + 1)
      handled = true
    elseif command == "action" then
      sol.audio.play_sound("misc/low_health")
      if self.cursor_position == 1 then
        -- Change the video mode.
        sol.video.switch_mode()
        self.video_mode_text:set_text(sol.video.get_mode())
      else
        -- Customize a game command.
        self:set_caption_key("options.caption.press_key")
        self.waiting_for_command = true
        local command_to_customize = self.command_names[self.cursor_position - 1]
        self.game:capture_command_binding(command_to_customize, function()
          self.waiting_for_command = false
          sol.audio.play_sound("misc/low_health")
          self:set_caption_key("options.caption.press_action_customize_key")
          self:load_command_texts()
          -- TODO restore HUD icons.
        end)

        -- TODO grey over HUD icons, make the icon of the command blink.
      end
      handled = true
    end
  end

  return handled
end

return options_submenu