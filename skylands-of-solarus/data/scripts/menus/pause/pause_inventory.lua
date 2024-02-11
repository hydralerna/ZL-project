local submenu = require("scripts/menus/pause/pause_submenu")
local text_fx_helper = require("scripts/text_fx_helper")
local info_manager = require("scripts/info_manager")

local inventory_submenu = submenu:new()
local item_names_assignable = {
  "potions/life_potion",
  "potions/healing_potion",
  "potions/magic_potion"
}
local item_names_static = {
  "sword"
}


-- print(table.concat(item_names_assignable ,", "))

function inventory_submenu:on_started()

  submenu.on_started(self)


local test_inventory = {}

--[[
for i, item_name in ipairs(item_names_assignable) do
   local item = self.game:get_item(item_name)
   local item_info = {item_name, item:get_variant(), item:get_amount(), item:get_max_amount()}
   test_inventory["slot" .. i] = tostring("{" .. table.concat(item_info, ", ") .. "}")
   self.game:set_value("inventory_slot" .. i, test_inventory["slot" .. i] )
end
--info_manager:create_sol_file("inventory.dat", test_inventory)
--]]

  --self.game:set_table_value("equipped_potions", test_inventory)

  local saved_potions = self.game:get_table_value("equipped_potions")
  if not saved_potions then saved_potions = {} end
  self.game.equipped_potions = {}
  for slot, slot_info in pairs(saved_potions) do
    print(slot .. " " .. slot_info)
  end


  print("inventory_submenu:on_started()")
  -- Set title
  self:set_title(sol.language.get_string("inventory.title"))

  -- Cursor and arrow
  self.cursor_sprite1 = sol.sprite.create("menus/pause/cursor_"  .. submenu.theme)
  self.cursor_sprite2 = sol.sprite.create("menus/pause/cursor_"  .. submenu.theme)
  self.arrow_sprite1u = sol.sprite.create("menus/pause/arrow_"  .. submenu.theme)
  self.arrow_sprite1d = sol.sprite.create("menus/pause/arrow_"  .. submenu.theme)
  self.arrow_sprite2d = sol.sprite.create("menus/pause/arrow_" .. submenu.theme)

  -- Small icons for SAVE or other options
  self.options_icon = sol.sprite.create("menus/pause/options_icon_" .. submenu.theme)
  self.save_icon = sol.sprite.create("menus/pause/save_icon_" .. submenu.theme)  
  self.show_options1 = false

  -- Set cells
  self.cell_size = 18
  self.cell_spacing = 2
  local cell = self.cell_size + self.cell_spacing 
  self.nb_cells_x = 3
  self.nb_cells_y = 8
  self.cells1_surface = sol.surface.create(cell * self.nb_cells_x - self.cell_spacing , cell * self.nb_cells_y - self.cell_spacing )
  self.cells2_surface = sol.surface.create(cell * self.nb_cells_x - self.cell_spacing , cell * self.nb_cells_y - self.cell_spacing )

  -- Text colors
  self.font_color = {143, 192, 112}
  self.font_fx_color = {224, 255, 208}
  self.font_stroke_color = {15, 31, 32}

  -- Sprites
  self.sprites_assignables = {}
  self.sprites_static = {}
  --self.captions = {}
  self.counters = {}

  -- Initialize the cursor
  local index = self.game:get_value("pause_inventory_last_item_index") or 0
  --print("cursor_row: ".. self.game:get_value("cursor_row"))
  local cursor_row = self.game:get_value("cursor_row") or 0
  local cursor_column = self.game:get_value("cursor_column") or 1
  self.cursor1_row = 0
  self.cursor1_column = 1
  self.cursor2_row = 0
  self.cursor2_column = 1
  if submenu.sprite == 1 then
    self.show_cursor1 = true
    self.show_cursor2 = false
    self:set_cursor1_position(cursor_row, cursor_column)
    self:set_cursor2_position(self.cursor2_row, self.cursor2_column)
    self.arrow_sprite1u:set_direction(1)
    self.arrow_sprite1d:set_direction(1)
    self.arrow_sprite2d:set_direction(3)
    if self.cursor1_row == 0 and self.cursor1_column == 1 then
      self.show_arrow1 = true
      self.arrow_sprite1d:set_animation("dynamic")
    else
      self.show_arrow1 = false
      self.arrow_sprite1d:set_animation("static")
    end
  else
    self.show_cursor2 = true
    self.show_cursor1 = false
    self:set_cursor2_position(cursor_row, cursor_column)
    self:set_cursor1_position(self.cursor1_row, self.cursor1_column)
    self.arrow_sprite1u:set_direction(1)
    self.arrow_sprite1d:set_direction(3)
    self.arrow_sprite2d:set_direction(1)
    if self.cursor2_row == 0 and self.cursor2_column == 1 then
      self.show_arrow2 = true
      self.arrow_sprite2d:set_animation("dynamic")
    else
      self.show_arrow2 = false
      self.arrow_sprite2d:set_animation("static")
    end
  end

  -- 
  self.game:set_custom_command_effect("attack", nil) -- KO

  -- Load Items
  for i, item_name in ipairs(item_names_assignable) do
    local item = self.game:get_item(item_name)
    local variant = item:get_variant()
    if item:has_amount() then
      local amount = item:get_amount()
      if amount > 0 then
        self.sprites_assignables[i] = sol.sprite.create("entities/items")
        self.sprites_assignables[i]:set_animation(item_name)
        -- Show a counter in this case.
        local maximum = item:get_max_amount()
        self.counters[i] = sol.text_surface.create{
          horizontal_alignment = "right",
          vertical_alignment = "bottom",
          text = item:get_amount(),
          font = "enter_command",
          color = (amount == maximum) and self.font_fx_color or self.font_color,
          font_size = 16
        }
      end
    end
  end
  
  for i,item_name in ipairs(item_names_static) do
    local item = self.game:get_item(item_name)
    local variant = item:get_variant()
    self.sprites_static[i] = sol.sprite.create("entities/items")
    self.sprites_static[i]:set_animation(item_name)
  end

end


function inventory_submenu:on_finished()

  print("inventory_submenu:on_finished()")
  self.game:set_value("submenu_bg_icon_sprite", submenu.sprite)
  if submenu.sprite == 1 and self.show_cursor1 then
    self.game:set_value("cursor_row", self.cursor1_row)
    self.game:set_value("cursor_column", self.cursor1_column)
  elseif submenu.sprite == 2 and self.show_cursor2 then
    self.game:set_value("cursor_row", self.cursor2_row)
    self.game:set_value("cursor_column", self.cursor2_column)
  else
    self.game:set_value("cursor_row", 0)
    self.game:set_value("cursor_column", 1)
  end
end


function inventory_submenu:on_draw(dst_surface)

  local sz = self.cell_size
  local sp = self.cell_spacing
  local ss = self.cell_size + self.cell_spacing
  local xn = self.nb_cells_x - 1
  local yn = self.nb_cells_y - 1
  -- Draw the background.
  self:draw_background(dst_surface, false)
  self.cells1_surface:draw(dst_surface, 6, 44)
  self.cells2_surface:draw(dst_surface, 320, 44)
  -- Cells
  for yc = 0, ss * yn, ss do
    for xc = 0, ss * xn, ss do
      self.cells1_surface:fill_color(submenu.theme_colors[submenu.theme][2], xc + 1, yc, sz - 2, sz)
      self.cells1_surface:fill_color(submenu.theme_colors[submenu.theme][2], xc, yc + 1, sz, sz - 2)
      if yc < (ss * 3) or yc > (ss * 4) then
        self.cells2_surface:fill_color(submenu.theme_colors[submenu.theme][2], xc + 1, yc, sz - 2, sz)
        self.cells2_surface:fill_color(submenu.theme_colors[submenu.theme][2], xc, yc + 1, sz, sz - 2)
      end
      xc = xc + ss
    end
  end
  -- Draw each inventory assignable item.
  local y = 56
  local k = 0

  for i = 0, 3 do
    local x = 14
    for j = 0, 2 do
      if i == 3 and j == 0 then
        x = x + sz + sp
      end
      k = k + 1
      if item_names_assignable[k] ~= nil then
        local item = self.game:get_item(item_names_assignable[k])
        if item:get_amount() > 0 then
          -- The player has this item: draw it.
          self.sprites_assignables[k]:set_direction(item:get_variant() - 1)
          self.sprites_assignables[k]:draw(dst_surface, x, y)
          if self.counters[k] ~= nil then
            --self.counters[k]:draw(dst_surface, x + 8, y + 6)
            self.counters[k]:set_xy(x + 8, y + 6)
            text_fx_helper:draw_text_with_stroke(dst_surface, self.counters[k], self.font_stroke_color)
          end
        end
      end
      x = x + sz + sp
    end
    y = y + sz + sp
  end
  -- Draw cursor only when the save dialog is not displayed.
  if not self.dialog_opened then
    self.arrow_sprite1u:draw(dst_surface, 35, 8)
    self.arrow_sprite1d:draw(dst_surface, 35, 42)
    self.arrow_sprite2d:draw(dst_surface, 349, 42)
    if self.show_cursor1 then
      self.cursor_sprite1:draw(dst_surface, 5 + ss * self.cursor1_column, 43 + ss * self.cursor1_row)
    end
    if self.show_cursor2 then
      self.cursor_sprite2:draw(dst_surface, 319 + ss * self.cursor2_column, 43 + ss * self.cursor2_row)
    end
  end

  -- Draw small icons for SAVE or other options
  self.options_icon:draw(dst_surface, 35, 2)
  if self.show_options1 then
    self.save_icon:draw(dst_surface, 35, 25)
  end

end


function inventory_submenu:set_cursor1_position(row, column)
  self.cursor1_row = row
  self.cursor1_column = column
  -- TODO

end


function inventory_submenu:set_cursor2_position(row, column)
  self.cursor2_row = row
  self.cursor2_column = column
  -- TODO

end


function inventory_submenu:on_command_pressed(command)
  local handled = submenu.on_command_pressed(self, command)

  if not handled then

    if command == "action"  then
      if self.game:get_command_effect("action") == nil and self.game:get_custom_command_effect("action") == "info" then
        if not self.dialog_opened then
          handled = true
          self:show_info_message()
        else
          handled = false
        end
      end

    elseif command == "attack"  then
      if submenu.sprite == 1 and self.show_options1 then
        handled = true
        self:show_save_messagebox()
        print"attack"
        self.arrow_sprite1u:set_direction(1)
        self.arrow_sprite1u:set_animation("static")
        self.options_icon:set_direction(3)
        self:set_bg_icon(submenu.sprite, "appearing1")
        print("HIDE OPTIONS")
        self.show_options1 = false
      end
    elseif command == "item_1" then
      if self:is_item_selected() or (self.cursor1_row == 0 and self.cursor1_column > 2)  then
        self:assign_item(1)
        handled = true
      end

    elseif command == "item_2" then
      if self:is_item_selected()  or (self.cursor1_row == 0 and self.cursor1_column > 2) then
        self:assign_item(2)
        handled = true
      end

    elseif command == "left" then
      --TODO self:previous_submenu()
      if submenu.sprite == 1 and self.show_options1 then
        sol.audio.play_sound("menus/menu_cursor")
      elseif submenu.sprite == 1 and self.show_cursor1 then
        sol.audio.play_sound("menus/menu_cursor")
        self:set_cursor1_position(self.cursor1_row, (self.cursor1_column + 2) % 3)
      elseif submenu.sprite == 2 and self.show_cursor2 then
        sol.audio.play_sound("menus/menu_cursor")
        self:set_cursor2_position(self.cursor2_row, (self.cursor2_column + 2) % 3)
      elseif submenu.sprite == 2 and not self.show_cursor2 then
        self.arrow_sprite2d:set_direction(1)
        self:set_bg_icon(submenu.sprite, "disappearing2")
        sol.audio.play_sound("menus/solarus_logo")
        self.show_cursor1 = false
        submenu.sprite = 1
        self.arrow_sprite1u:set_animation("dynamic")
        self.options_icon:set_animation("dynamic")
        self.arrow_sprite1d:set_direction(3)
        self:set_bg_icon(submenu.sprite, "appearing2")
      else
        self.show_cursor1 = false
        self.show_cursor2 = false
      end
      handled = true

    elseif command == "right" then
      if submenu.sprite == 1 and self.show_options1 then
        sol.audio.play_sound("menus/menu_cursor")
      elseif submenu.sprite == 1 and self.show_cursor1 then
        sol.audio.play_sound("menus/menu_cursor")
        self:set_cursor1_position(self.cursor1_row, (self.cursor1_column + 1) % 3)
      elseif submenu.sprite == 2 and self.show_cursor2 then
        sol.audio.play_sound("menus/menu_cursor")
        self:set_cursor2_position(self.cursor2_row, (self.cursor2_column + 1) % 3)
      elseif submenu.sprite == 1 and not self.show_cursor1 then
        self.arrow_sprite1d:set_direction(1)
        self:set_bg_icon(submenu.sprite, "disappearing2")
        sol.audio.play_sound("menus/solarus_logo")
        self.show_cursor2 = false
        submenu.sprite = 2
        self.arrow_sprite1u:set_animation("static")
        self.options_icon:set_animation("static")
        self.arrow_sprite2d:set_direction(3)
        self:set_bg_icon(submenu.sprite, "appearing2")
      else
        self:next_submenu()
        --index_palette_shader:set_palette()
        self.show_cursor1 = false
        self.show_cursor2 = false
      end
      handled = true

    elseif command == "up" then
      if submenu.sprite == 1 and self.show_options1 == false
       and self.options_icon:get_animation() == "dynamic" then
        self.arrow_sprite1u:set_direction(3)
        self.arrow_sprite1u:set_animation("dynamic")
        self.arrow_sprite1d:set_animation("static")
        self.options_icon:set_direction(1)
        self:set_bg_icon(submenu.sprite, "dynamic")
        local bg_icon_sprite = self:get_icon_bg_sprite(submenu.sprite)
        bg_icon_sprite:synchronize(self.save_icon)
        self.game:set_custom_command_effect("attack", "save")
        print("SHOW OPTIONS")
        self.show_options1 = true
      elseif submenu.sprite == 1 and self.show_cursor1 then
        if self.show_arrow1 then
          sol.audio.play_sound("menus/solarus_logo")
          self.arrow_sprite1u:set_animation("dynamic")
          self.options_icon:set_animation("dynamic")
          self.arrow_sprite1d:set_direction(3)
          self.show_cursor1 = false
          self:set_bg_icon(submenu.sprite, "appearing1")
        else
          sol.audio.play_sound("menus/menu_cursor")
          self:set_cursor1_position((self.cursor1_row + 7) % 8, self.cursor1_column)
        end
      elseif submenu.sprite == 2 and self.show_cursor2 then
        if self.show_arrow2 then
          sol.audio.play_sound("menus/solarus_logo")
          self.arrow_sprite1u:set_animation("static")
          self.options_icon:set_animation("static")
          self.arrow_sprite2d:set_direction(3)
          self.show_cursor2 = false
          self:set_bg_icon(submenu.sprite, "appearing1")
        else
          sol.audio.play_sound("menus/menu_cursor")
          local offset = 7
          if self.cursor2_row > 2 and self.cursor2_row <= 5 then
            offset = 5
          end
          self:set_cursor2_position((self.cursor2_row + offset) % 8, self.cursor2_column)
        end
      end
      handled = true

    elseif command == "down" then
      sol.audio.play_sound("menus/menu_cursor")
      if submenu.sprite == 1 and self.show_options1 then
        self.arrow_sprite1u:set_direction(1)
        self.arrow_sprite1u:set_animation("static")
        self.options_icon:set_direction(3)
        self:set_bg_icon(submenu.sprite, "appearing1")
        print("HIDE OPTIONS")
        self.show_options1 = false
        self.game:set_custom_command_effect("attack", nil)
      elseif submenu.sprite == 1 and not self.show_cursor1 then
          self.arrow_sprite1d:set_direction(1)
          self.arrow_sprite1u:set_animation("static")
          self.options_icon:set_animation("static")
          self.show_cursor1 = true
          self:set_bg_icon(submenu.sprite, "disappearing1")
      elseif submenu.sprite == 2 and not self.show_cursor2 then
          self.arrow_sprite2d:set_direction(1)
          self.show_cursor2 = true
          self:set_bg_icon(submenu.sprite, "disappearing1")
      elseif submenu.sprite == 1 and self.show_cursor1 then
          self:set_cursor1_position((self.cursor1_row + 1) % 8, self.cursor1_column)
      else
          local offset = 1
          if self.cursor2_row >= 2 and self.cursor2_row < 5 then
            offset = 3
          end
          self:set_cursor2_position((self.cursor2_row + offset) % 8, self.cursor2_column)
      end
      handled = true

    end
    if submenu.sprite == 1  and self.cursor1_row == 0 and self.cursor1_column == 1 and not self.show_options1 then
      self.arrow_sprite1d:set_animation("dynamic")
      self.show_arrow1 = true
    else
      self.arrow_sprite1d:set_animation("static")
      self.show_arrow1 = false
    end
    if submenu.sprite == 2 and self.cursor2_row == 0 and self.cursor2_column == 1 then
      self.arrow_sprite2d:set_animation("dynamic")
      self.show_arrow2 = true
    else
      self.arrow_sprite2d:set_animation("static")
      self.show_arrow2 = false
    end
  end

  return handled

end


function inventory_submenu:get_item_name(row, column)

   --print("debug: ------------inventory_submenu:get_item_name------------")
   --print("get_item_name_row", row, "get_item_name_column", column)
   local item_name = nil
   if column >= 0 and column < 4 then
      local index = row * 3 + column + 1
      item_name = item_names_assignable[index]
      -- print("item_name (from get...): " .. item_name .. ", row: " .. row .. ", column: " .. column)
    --[[
   elseif column == 4 then
      item_name = "melody_1"
   elseif column == 5 then
      item_name = "melody_2"
   elseif column == 6 then
      item_name = "melody_3"
   else
      index = row 
      item_name = item_names_static[index + 1]
   --]]
  end

  return item_name

end

function inventory_submenu:is_item_selected()

  -- print("debug: ------------inventory_submenu:is_item_selected------------")
  local item_name = self:get_item_name(self.cursor1_row, self.cursor1_column)
  -- print("ITEM NAME (in is_item...): ", item_name)
  local bool = false
  if item_name ~= nil then
    bool = self.game:get_item(item_name):get_variant() + 1 > 0
  end
  -- print("item_name: ", item_name, "Cursor1_row:", self.cursor1_row, "Cursor1_column", self.cursor1_column)
  return bool
end


-- Assigns the selected item to a slot (1 or 2).
-- The operation does not take effect immediately: the item picture is thrown to
-- its destination icon, then the assignment is done.
-- Nothing is done if the item is not assignable.
function inventory_submenu:assign_item(slot)

  local item_name = self:get_item_name(self.cursor1_row, self.cursor1_column)
  local item = self.game:get_item(item_name)

  -- If this item is not assignable, do nothing.
  if not item:is_assignable() then
    return
  end

  -- If another item is being assigned, finish it immediately.
  if self:is_assigning_item() then
    self:finish_assigning_item()
  end

  -- Memorize this item.
  self.item_assigned = item
  self.item_assigned_sprite = sol.sprite.create("entities/items")
  self.item_assigned_sprite:set_animation(item_name)
  self.item_assigned_sprite:set_direction(item:get_variant() - 1)
  self.item_assigned_destination = slot

  -- Play the sound.
  sol.audio.play_sound("menus/menu_select")

  -- TODO movement
  self:finish_assigning_item()
end


-- Returns whether an item is currently being thrown to an icon.
function inventory_submenu:is_assigning_item()

  return self.item_assigned_sprite ~= nil
end


-- Stops assigning the item right now.
-- This function is called when we want to assign the item without
-- waiting for its throwing movement to end, for example when the inventory submenu
-- is being closed.
function inventory_submenu:finish_assigning_item()

  -- If the item to assign is already assigned to the other icon, switch both items.
  local slot = self.item_assigned_destination
  local current_item = self.game:get_item_assigned(slot)
  local other_item = self.game:get_item_assigned(3 - slot)

  if other_item == self.item_assigned then
    self.game:set_item_assigned(3 - slot, current_item)
  end
  self.game:set_item_assigned(slot, self.item_assigned)

  -- self.item_assigned_sprite:stop_movement()
  self.item_assigned_sprite = nil
  self.item_assigned = nil
end


return inventory_submenu
