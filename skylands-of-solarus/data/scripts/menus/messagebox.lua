-- Simple message box dialog.

local automation = require("scripts/automation/automation")
local language_manager = require("scripts/language_manager")
local game_manager = require("scripts/game_manager")

local messagebox_builder = {}

local darken_background = true

function messagebox_builder:show(context, text_lines, button_1_text, button_2_text, default_button_index, callback)
  
  -- Creates the menu.
  local messagebox_menu = {}

  -- Callded when the menu is started.
  function messagebox_menu:on_started()
    -- Fix the font shift (issue with some fonts)
    messagebox_menu.font_y_shift = 0

    -- Create static surfaces.
    messagebox_menu.frame_img = sol.surface.create("menus/messagebox/messagebox_frame.png")
    messagebox_menu.frame_w, messagebox_menu.frame_h = messagebox_menu.frame_img:get_size()
    messagebox_menu.surface = sol.surface.create(messagebox_menu.frame_w, messagebox_menu.frame_h)
    messagebox_menu.button_img = sol.surface.create("menus/messagebox/messagebox_button.png")

    local quest_w, quest_h = sol.video.get_quest_size()
    messagebox_menu.dark_surface = sol.surface.create(quest_w, quest_h)
    messagebox_menu.dark_surface:fill_color({112, 112, 112})
    messagebox_menu.dark_surface:set_blend_mode("multiply")

    -- Create sprites.
    messagebox_menu.cursor_sprite = sol.sprite.create("menus/messagebox/messagebox_cursor")

    -- Get fonts.
    local menu_font, menu_font_size = language_manager:get_menu_font()
    messagebox_menu.menu_font = menu_font
    messagebox_menu.menu_font_size = menu_font_size
    messagebox_menu.text_color = { 115, 59, 22 }
    messagebox_menu.text_color_light = { 177, 146, 116 }

    -- Elements positions relative to messagebox_menu.surface.
    messagebox_menu.button_2_x = 136
    messagebox_menu.button_y = messagebox_menu.frame_h - 28
    messagebox_menu.cursor_x = 0
    messagebox_menu.cursor_y = 0
    messagebox_menu.text_y = 16

    -- Prepare texts.
    messagebox_menu.text_lines = {}
    for i = 1, 3 do
      local text_line = sol.text_surface.create{
        color = messagebox_menu.text_color,
        font = messagebox_menu.menu_font,
        font_size = messagebox_menu.menu_font_size,
        horizontal_alignment = "center",
      }
      messagebox_menu.text_lines[i] = text_line
    end

    messagebox_menu.buttons = {}  
    messagebox_menu.buttons[1] = { 
      x = 24,
      text = sol.text_surface.create{
        color = messagebox_menu.text_color,
        font = messagebox_menu.menu_font,
        font_size = messagebox_menu.menu_font_size,
        horizontal_alignment = "center",
      }
    }
    messagebox_menu.buttons[2] = {
      x = 136,
      text = sol.text_surface.create{
        color = messagebox_menu.text_color,
        font = messagebox_menu.menu_font,
        font_size = messagebox_menu.menu_font_size,
        horizontal_alignment = "center",
      }
    }
    messagebox_menu.button_count = 2

    -- Callback when the menu is done.
    messagebox_menu.callback = function(result)
    end

    -- We handle command bindings manually because of the order of events in 1.6.
    messagebox_menu.command_bindings = { 
      ["action"] = "",
      ["attack"] = "",
      ["left"] = "",
      ["right"] = "",
      ["pause"] = "",
    }
    
    local function invert_table(t)
      local s = {}
      for k, v in pairs(t) do
        s[v] = k
      end
      return s
    end

    local game = sol.main.game
    if game ~= nil then
      -- Retrieve the keyboard bindings.
      for key, _  in pairs(messagebox_menu.command_bindings) do
        messagebox_menu.command_bindings[key] = game:get_command_keyboard_binding(key)
      end
      -- Invert the table for better performance when looking for a key.
      messagebox_menu.command_bindings = invert_table(messagebox_menu.command_bindings)

      -- Custom commands effects
      if game.set_custom_command_effect ~= nil then
        -- Backup the current actions.
        messagebox_menu.backup_actions = {
          ["action"] = "",
          ["attack"] = "",
        }
        for key, _  in pairs(messagebox_menu.backup_actions) do
          messagebox_menu.backup_actions[key] = game:get_custom_command_effect(key)
        end

        -- Set the new ones.
        local new_actions = {
          ["action"] = "validate",
          ["attack"] = "return",
        }
        for key, value in pairs(new_actions) do
          game:set_custom_command_effect(key, value)
        end
      
      else
        messagebox_menu.backup_actions = {
          ["action"] = "",
          ["attack"] = "",
        }
      end

      -- Set the HUD on top.
      game:bring_hud_to_front()

      -- Set the correct HUD mode.
      messagebox_menu.backup_hud_mode = game:get_hud_mode()
      game:set_hud_mode("dialog")
    else
      messagebox_menu.backup_actions = {
        ["action"] = "",
        ["attack"] = "",
      }
    end

    -- Animate the movement.
    local frame_x, frame_y = math.ceil((quest_w - messagebox_menu.frame_w) / 2), math.ceil((quest_h - messagebox_menu.frame_h) / 2)
    self.surface:set_xy(frame_x, frame_y + 32)
    messagebox_menu.opening_automation = automation:new(messagebox_menu, self.surface, "cubic_out", 200, { y = frame_y })
    messagebox_menu.closing_automation = automation:new(messagebox_menu, self.surface, "cubic_out", 200, { y = frame_y + 64 })

    -- State.
    messagebox_menu.accepts_user_input = false
    messagebox_menu.step = "appearing"

    -- Run the menu.
    messagebox_menu.result = 2
    messagebox_menu.cursor_position = 1
    messagebox_menu:update_cursor()
    messagebox_menu:set_step("appearing")
  end

  -- Callded when the menu is finished.
  function messagebox_menu:on_finished()
    local game = sol.main.game
    if game ~= nil then
      -- Restore HUD mode.
      game:set_hud_mode(messagebox_menu.backup_hud_mode)
      
      -- Remove overriden command effects.
      if game.set_custom_command_effect ~= nil then
        for key, value in pairs(messagebox_menu.backup_actions) do
          game:set_custom_command_effect(key, value)
        end
      end
    end

    -- Calls the callback.
    messagebox_menu:done()
  end

  -- Draw the menu.
  function messagebox_menu:on_draw(dst_surface)

    -- Get the destination surface size to center everything.
    local width, height = dst_surface:get_size()
    
    -- Dark surface.
    if darken_background then
      messagebox_menu.dark_surface:draw(dst_surface, 0, 0)
    end
    
    -- Clear surface.
    messagebox_menu.surface:clear()
    
    -- Frame.
    messagebox_menu.frame_img:draw(messagebox_menu.surface, 0, 0)
     
    -- Text, vertically centered.
    for i = 1, #messagebox_menu.text_lines do
      local text_line = messagebox_menu.text_lines[i]
      local text_line_y = messagebox_menu.text_y + (i - 1) * messagebox_menu.menu_font_size * 2
      text_line:draw(messagebox_menu.surface, messagebox_menu.frame_w / 2, text_line_y + messagebox_menu.font_y_shift)
    end

    -- Buttons.
    for i = 1, messagebox_menu.button_count do
      local button_x = messagebox_menu.buttons[i].x
      local button_text = messagebox_menu.buttons[i].text
      messagebox_menu.button_img:draw(messagebox_menu.surface, button_x, messagebox_menu.button_y)
      button_text:draw(messagebox_menu.surface, button_x + 32, messagebox_menu.button_y + 8 + messagebox_menu.font_y_shift)
    end

    -- Cursor (if the position is valid).
    if messagebox_menu.cursor_position > 0 then
      -- Draw the cursor sprite.
      messagebox_menu.cursor_sprite:draw(messagebox_menu.surface, messagebox_menu.cursor_x, messagebox_menu.cursor_y)
    end

    -- dst_surface may be larger: draw this menu at the center.
    messagebox_menu.surface:draw(dst_surface)
  end

  -- Gets the current step.
  function messagebox_menu:get_step()
    return messagebox_menu.step
  end

  -- Sets the step.
  function messagebox_menu:set_step(step)
    if step == "appearing" then
      sol.audio.play_sound("menus/pause_menu_open")
      messagebox_menu.step = step
      messagebox_menu.accepts_user_input = false
      messagebox_menu.cursor_sprite:set_paused(true)
      messagebox_menu.cursor_sprite:set_frame(0)

      messagebox_menu.dark_surface:fade_in(5)
      messagebox_menu.opening_automation:start()
      messagebox_menu.surface:fade_in(10, function()
        messagebox_menu:set_step("wait_for_input")
      end)
      
    elseif step == "wait_for_input" then
      messagebox_menu.step = step
      messagebox_menu.accepts_user_input = true
      messagebox_menu.cursor_sprite:set_paused(false)
      
    elseif step == "disappearing" then
      sol.audio.play_sound("menus/pause_menu_close")
      messagebox_menu.step = step
      messagebox_menu.accepts_user_input = false
      messagebox_menu.cursor_sprite:set_paused(true)
      
      sol.timer.start(messagebox_menu, 200, function()
        messagebox_menu.dark_surface:fade_out(2)
        messagebox_menu.closing_automation:start()
        messagebox_menu.surface:fade_out(5, function()
          sol.menu.stop(messagebox_menu)
        end)
      end)
    end
  end

  ------------
  -- Cursor --
  ------------

  -- Update the cursor.
  function messagebox_menu:update_cursor()

    -- Update coordinates.
    if messagebox_menu.cursor_position > 0 and messagebox_menu.cursor_position <= messagebox_menu.button_count then
      messagebox_menu.cursor_x = messagebox_menu.buttons[messagebox_menu.cursor_position].x + 32
    else
      messagebox_menu.cursor_x = -999 -- Not visible
    end

    messagebox_menu.cursor_y = messagebox_menu.button_y + 8

    -- Restart the automation.
    messagebox_menu.cursor_sprite:set_frame(0)
  end

  -- Update the cursor position.
  function messagebox_menu:set_cursor_position(cursor_position)

    if cursor_position ~= messagebox_menu.cursor_position then
      messagebox_menu.cursor_position = cursor_position
      messagebox_menu:update_cursor()
    end
  end

  -- Notify that this cursor movement is not allowed.
  function messagebox_menu:notify_cursor_not_allowed()
    messagebox_menu.cursor_sprite:set_frame(0)
    sol.audio.play_sound("misc/error")   
  end


  --------------
  -- Commands --
  --------------

  -- Check if a game currently exists and is started.
  function messagebox_menu:is_game_started()
    
    if sol.main.game ~= nil then
      if sol.main.game:is_started() then
        return true
      end
    end
    return false

  end

  -- Handle player input.
  function messagebox_menu:on_command_pressed(command)

    if not messagebox_menu.accepts_user_input then
      return true
    end

    -- Action: click on the button.
    if command == "action" then
      if messagebox_menu.cursor_position == 1 then
        sol.audio.play_sound("menus/menu_cursor") 
        messagebox_menu:accept()
      else
        sol.audio.play_sound("menus/menu_cursor") 
        messagebox_menu:reject()
      end
    -- Left/Right: move the cursor.
    elseif command == "left" or command == "right" then
      if messagebox_menu.cursor_position == 1 and command == "right" then
        -- Go to button 2.
        messagebox_menu:set_cursor_position(2)
        sol.audio.play_sound("menus/menu_cursor")   
      elseif messagebox_menu.cursor_position == 2 and command == "left" then
        -- Go to button 1.
        messagebox_menu:set_cursor_position(1)
        sol.audio.play_sound("menus/menu_cursor")
      else
        -- Blocked.
        messagebox_menu:notify_cursor_not_allowed()
      end

      -- Don't propagate the event to anything below the dialog box.
      return true
    end
  end

  -- Hander player input when there is no lauched game yet.
  function messagebox_menu:on_key_pressed(key)
    
    if not messagebox_menu.accepts_user_input then
      return true
    end

    if not messagebox_menu:is_game_started() then
      -- Escape: cancel the dialog (same as choosing No).
      if key == "escape" then
        messagebox_menu:reject()
      -- Left/right: moves the cursor.
      elseif key == "left" or key == "right" then
        if messagebox_menu.cursor_position == 1 and key == "right" then
          -- Go to button 2.
          messagebox_menu:set_cursor_position(2)
          sol.audio.play_sound("menus/menu_cursor")    
        elseif messagebox_menu.cursor_position == 2 and key == "left" then
          -- Go to button 1.
          messagebox_menu:set_cursor_position(1)
          sol.audio.play_sound("menus/menu_cursor")
        else
          -- Blocked.
          messagebox_menu:notify_cursor_not_allowed()
        end
      -- Up/down: blocked.
      elseif key == "up" or key == "down" then
        messagebox_menu:notify_cursor_not_allowed()
      -- Space/Return: validate the button at the cursor.
      elseif key == "space" or key == "return" then
        if messagebox_menu.cursor_position == 1 then
          messagebox_menu:accept()
        else
          messagebox_menu:reject()
        end
      end
    end

    -- Try to bind this key on a command.
    local command = messagebox_menu.command_bindings[key]
    if command ~= nil then
      messagebox_menu:on_command_pressed(command)
    end
    
    -- Don't propagate the event to anything below the dialog box.
    return true
  end

  ------------------------
  -- Messagebox related --
  ------------------------

  -- Show the messagebox with the text in parameter.
  function messagebox_menu:show(context, text_lines, button_1_text, button_2_text, default_button_index, callback)

    -- Show the menu.
    sol.menu.start(context, messagebox_menu, true)
    
    -- Text.
    local line_1 = text_lines[1] or ""
    local line_2 = text_lines[2] or ""
    local line_3 = text_lines[3] or ""

    messagebox_menu.text_lines[1]:set_text(line_1)
    messagebox_menu.text_lines[2]:set_text(line_2)
    messagebox_menu.text_lines[3]:set_text(line_3)

    -- Buttons.
    local button_1_text = button_1_text or sol.language.get_string("messagebox.yes")
    local button_2_text = button_2_text or sol.language.get_string("messagebox.no")

    messagebox_menu.buttons[1].text:set_text(button_1_text)
    messagebox_menu.buttons[2].text:set_text(button_2_text)

    -- Callback to call when the messagebox is closed.
    messagebox_menu.callback = callback

    -- Default cursor position.
    if default_button_index > 0 and default_button_index <= messagebox_menu.button_count then
      messagebox_menu:set_cursor_position(default_button_index)
    else
      messagebox_menu:set_cursor_position(1)    
    end

  end

  -- Accept the messagebox (i.e. validate or choose Yes).
  function messagebox_menu:accept()
    messagebox_menu:set_step("disappearing")
    messagebox_menu.result = 1
  end

  -- Rejects the messagebox (i.e. cancel or choose No).
  function messagebox_menu:reject()
    messagebox_menu:set_step("disappearing")
    messagebox_menu.result = 2
  end

  -- Calls the callback when the messagebox is done.
  function messagebox_menu:done()
    if messagebox_menu.callback ~= nil then
      messagebox_menu.callback(messagebox_menu.result)
    end
  end

  ------------------------

  messagebox_menu:show(context, text_lines, button_1_text, button_2_text, default_button_index, callback)

end

return messagebox_builder
