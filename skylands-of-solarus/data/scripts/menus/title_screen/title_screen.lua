-- Title screen.
-- From a script by Olivier Clero
-- Modified by froggy77
-- Usage:
-- local title_screen = require("menus/title_screen")
-- sol.menu.start(title_screen)
-- title_screen.on_finished = function()
--   -- Do whatever you want next (start a game...)
-- end

local title_screen = {}

-- Called when the menu is started.
function title_screen:on_started()

  -- Keep trace of the current step.
  self.step = 0
  self.finished = false

  -- Adapt to the quest size.
  self.surface_w, self.surface_h = sol.video.get_quest_size()

  -- Load images

  -- Black surface for the fade-out after the animation
  self.black_surface = sol.surface.create(self.surface_w, self.surface_h)
  self.black_surface:fill_color({15, 31, 32})
  
  -- Background images
  self.sky = sol.surface.create(self.surface_w, 96)
  self.sky:fill_color({143, 192, 112})
  self.horizon = sol.surface.create("menus/title_screen/horizon.png")
  self.sun = sol.surface.create("menus/title_screen/sun.png")
  self.sun_w, self.sun_h = self.sun:get_size()
  self.sun_w = self.sun_w / 7
  self.clouds = sol.surface.create("menus/title_screen/clouds.png")
  self.clouds_w, self.clouds_h = self.clouds:get_size()
  -- Title
  self.title = sol.surface.create("menus/title_screen/title.png")
  self.title_w, self.title_h = self.title:get_size()
  -- Animated background images
  self.mountains_far = sol.surface.create("menus/title_screen/mountains_far.png")
  self.mountains_far_w, self.mountains_far_h = self.mountains_far:get_size()
  self.mountains = sol.surface.create("menus/title_screen/mountains.png")
  self.mountains_w, self.mountains_h = self.mountains:get_size()
  self.trees = sol.surface.create("menus/title_screen/trees.png")
  self.trees_w, self.trees_h = self.trees:get_size()
  self.foreground_trees = sol.surface.create("menus/title_screen/foreground_trees.png")
  self.foreground_trees_w, self.foreground_trees_h = self.foreground_trees:get_size()

  -- Variables for offsets
  self.x_offset_mountain_far = 0
  self.x_offset_mountains = 0
  self.x_offset_trees = 0
  self.x_offset_foreground_trees = 0

  -- Timer and offsets
  sol.timer.start(10, function()
    if self.x_offset_mountain_far < self.mountains_far_w then
      self.x_offset_mountain_far = self.x_offset_mountain_far + 0.1
    else
      self.x_offset_mountain_far = 0
    end
    if self.x_offset_mountains < self.mountains_w then
      self.x_offset_mountains = self.x_offset_mountains + 0.2
    else
      self.x_offset_mountains = 0
    end
    if self.x_offset_trees < self.trees_w then
      self.x_offset_trees = self.x_offset_trees + 0.3
    else
      self.x_offset_trees = 0
    end
    if self.x_offset_foreground_trees < self.foreground_trees_w then
      self.x_offset_foreground_trees = self.x_offset_foreground_trees + 0.4
    else
      self.x_offset_foreground_trees = 0
    end
    return true
  end)

end


-- Draws this menu.
function title_screen:on_draw(dst_surface)

  local dst_w, dst_h = dst_surface:get_size()
  -- NB: the order is important here to get the layers in the correct order.

  -- Background images

  -- Sky and horizon
  self.sky:draw(dst_surface, 0, 0)
  self.horizon:draw(dst_surface, 0, 96)
  -- Sun
  local sun_x = dst_w / 2 - 24
  self.sun:draw_region(288, 0, self.sun_w, self.sun_h, dst_surface, sun_x, 64)
  -- Clouds
  local clouds_x = (dst_w - self.clouds_w) / 2
  self.clouds:draw(dst_surface, clouds_x, 40)
  -- Title
  self.title:draw(dst_surface, 94, 34)

  -- Animated background images

  -- Far mountains
  local mountains_far_x = -self.x_offset_mountain_far
	local mountains_far_y = dst_h - self.mountains_far_h
  while mountains_far_x < self.surface_w do
    self.mountains_far:draw(dst_surface, mountains_far_x, mountains_far_y)
    mountains_far_x = mountains_far_x + self.mountains_far_w
  end
  -- Mountains
  local mountains_x = -self.x_offset_mountains
	local mountains_y = dst_h - self.mountains_h
  while mountains_x < self.surface_w do
    self.mountains:draw(dst_surface, mountains_x, mountains_y)
    mountains_x = mountains_x + self.mountains_w
  end
  -- Trees
  local trees_x = -self.x_offset_trees
  local trees_y = dst_h - self.trees_h
  while trees_x < self.surface_w do
    self.trees:draw(dst_surface, trees_x, trees_y)
    trees_x = trees_x + self.trees_w
  end
  -- Foreground trees
  local foreground_trees_x = -self.x_offset_foreground_trees
  local foreground_trees_y = dst_h - self.foreground_trees_h
  while foreground_trees_x < self.surface_w do
    self.foreground_trees:draw(dst_surface, foreground_trees_x, foreground_trees_y)
    foreground_trees_x = foreground_trees_x + self.foreground_trees_w
  end

end


-- Resets the timer.
function title_screen:reset_timer()

  if self.timer ~= nil then
    self.timer:stop()
    self.timer = nil
  end

end


-- Called when a keyboard key is pressed.
function title_screen:on_key_pressed(key)

  if key == "escape" then
    -- Escape: quit Solarus.
    sol.main.exit()
    return true
  elseif not self.finished then
    self:skip_menu()
    return true
  end
  
  return false
end


-- Called when a mouse button is pressed.
function title_screen:on_mouse_pressed(button, x, y)

  if not self.finished and (button == "left" or button == "right") then
    self:skip_menu()
  end

end


-- Skips the menu.
function title_screen:skip_menu()

  if not sol.menu.is_started(self) or self.finished then
    return
  end

  -- Store the state.
  self.finished = true

  -- Stop the timer.
  self:reset_timer()

  -- Quits after a fade to black.
  self.black_surface:fade_in(20, function()
    -- Quit the menu
    sol.menu.stop(self)
  end)

end

-- Return the menu to the caller.
return title_screen
