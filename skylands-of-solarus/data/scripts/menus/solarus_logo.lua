-- Animated Solarus logo by Maxs.
-- Modified by Alex Gleason.
-- Modified by froggy77. This script is suitable for black backgrounds. Add the variables "quest_width" and "quest_height" for more flexibility.

-- You may include this logo in your quest to show that you use Solarus,
-- but this is not mandatory.

-- Example of use:
-- local solarus_logo = require("menus/solarus_logo")
-- sol.menu.start(solarus_logo)
-- function solarus_logo:on_finished()
--   -- Do whatever you want next (show a title screen, start a game...)
-- end
local solarus_logo_menu = {}

-- Black background
local quest_width, quest_height = sol.video.get_quest_size()
local background = sol.surface.create(quest_width, quest_height)
background:fill_color{15, 31, 32}

-- Main surface of the menu.
local logo_surface = sol.surface.create(145, 34)

-- Solarus title sprite.
local title = sol.sprite.create("menus/solarus_logo/solarus_logo")
title:set_animation("title")

-- Solarus subtitle sprite.
local subtitle = sol.sprite.create("menus/solarus_logo/solarus_logo")
subtitle:set_animation("subtitle")

-- Sun sprite.
local sun = sol.sprite.create("menus/solarus_logo/solarus_logo")
sun:set_animation("sun")

-- Sword sprite.
local sword = sol.sprite.create("menus/solarus_logo/solarus_logo")
sword:set_animation("sword")

-- Black square below the sun.
local black_square = sol.surface.create(32, 16)
black_square:fill_color{15, 31, 31}

-- Step of the animation.
local animation_step = 0

-- Time handling.
local timer = nil

-------------------------------------------------------------------------------

-- Rebuilds the whole surface of the menu.
local function rebuild_surface()

  logo_surface:fill_color{15, 31, 31}

  -- Draw the title (after step 1).
  if animation_step >= 1 then
    title:draw(logo_surface)
  end

  -- Draw the sun.
  sun:draw(logo_surface, 18, 32)

  -- Draw the black square to partially hide the sun.
  black_square:draw(logo_surface, 18, 23)

  -- Draw the sword.
  sword:draw(logo_surface, 50, -27)

  -- Draw the subtitle (after step 2).
  if animation_step >= 2 then
    subtitle:draw(logo_surface, 0, 26)
  end
end

-------------------------------------------------------------------------------

-- Starting the menu.
function solarus_logo_menu:on_started()

  -- Initialize or reinitialize the animation.
  animation_step = 0
  timer = nil
  logo_surface:set_opacity(255)
  sun:set_direction(0)
  sun:set_xy(0, 0)
  sword:set_xy(0, 0)
  -- Start the animation.
  solarus_logo_menu:start_animation()

  -- TEST: shader
  --local shader = sol.shader.create("film_grain")
  --shader:set_uniform("custom", true)
  --[[
  shader:set_uniform("bgcolor", {.5, .5, .5, 1.0})
  shader:set_uniform("slowness", 10.0)
  shader:set_uniform("cos_x", false)
  shader:set_uniform("cos_y", true)
  shader:set_uniform("distortion_x", 5.0)
  shader:set_uniform("distortion_y", 5.0)
  shader:set_uniform("scale_x", 5.0)
  shader:set_uniform("scale_y", 5.0)
  --]]
  --sol.video.set_shader(shader)

  -- Update the surface.
  rebuild_surface()
end

-- Animation step 1.
function solarus_logo_menu:step1()

  animation_step = 1
  -- Change the sun color.
  sun:set_direction(1)
  -- Stop movements and replace elements.
  sun:stop_movement()
  sun:set_xy(0, -32)
  sword:stop_movement()
  sword:set_xy(-34, 33)
  -- Play a sound.
  sol.audio.play_sound("menus/solarus_logo")
  -- Update the surface.
  rebuild_surface()
end

-- Animation step 2.
function solarus_logo_menu:step2()

  animation_step = 2
  -- Update the surface.
  rebuild_surface()
  -- Start the final timer.
  sol.timer.start(solarus_logo_menu, 500, function()
    logo_surface:fade_out()
    sol.timer.start(solarus_logo_menu, 700, function()
      sol.menu.stop(solarus_logo_menu)
    end)
  end)
end

-- Run the logo animation.
function solarus_logo_menu:start_animation()

  -- Move the sun.
  local sun_movement = sol.movement.create("target")
  sun_movement:set_speed(64)
  sun_movement:set_target(0, -32)
  -- Update the surface whenever the sun moves.
  function sun_movement:on_position_changed()
    rebuild_surface()
  end

  -- Move the sword.
  local sword_movement = sol.movement.create("target")
  sword_movement:set_speed(64)
  sword_movement:set_target(-34, 33)

  -- Update the surface whenever the sword moves.
  function sword_movement:on_position_changed()
    rebuild_surface()
  end

  -- Start the movements.
  sun_movement:start(sun, function()
    sword_movement:start(sword, function()

      if not sol.menu.is_started(solarus_logo_menu) then
        -- The menu may have been stopped, but the movement continued.
        return
      end

      -- If the animation step is not greater than 0
      -- (if no key was pressed).
      if animation_step <= 0 then
        -- Start step 1.
        solarus_logo_menu:step1()
        -- Create the timer for step 2.
        timer = sol.timer.start(solarus_logo_menu, 250, function()
          -- If the animation step is not greater than 1
          -- (if no key was pressed).
          if animation_step <= 1 then
            -- Start step 2.
            solarus_logo_menu:step2()
          end
        end)
      end
    end)
  end)
end


-- Resets the timer.
function solarus_logo_menu:reset_timer()

  if self.timer ~= nil then
    self.timer:stop()
    self.timer = nil
  end

end


-- Skips the menu.
function solarus_logo_menu:skip_menu()

  if not sol.menu.is_started(self) or self.finished then
    return
  end

  -- Store the state.
  self.finished = true

  -- Stop the timer.
  self:reset_timer()

  -- Quits after a fade to black.
  background:fade_in(20, function()
    -- Quit the menu
    sol.menu.stop(self)
  end)

end


-- Draws this menu on the quest screen.
function solarus_logo_menu:on_draw(screen)

  -- Get the screen size.
  local width, height = screen:get_size()

  -- Draw background
  background:draw(screen)

  -- Center the surface in the screen.
  logo_surface:draw(background, width / 2 - 72, height / 2 - 25)
end

-- Called when a keyboard key is pressed.
function solarus_logo_menu:on_key_pressed(key)

  if key == "escape" then
    -- Escape: skip Solarus logo.
    --sol.menu.stop(solarus_logo_menu)
    solarus_logo_menu:skip_menu()
  else
    -- If the timer exists (after step 1).
    if timer ~= nil then
      -- Stop the timer.
      timer:stop()
      timer = nil
      -- If the animation step is not greater than 1
      -- (if the timer has not expired in the meantime).
      if animation_step <= 1 then
        -- Start step 2.
        solarus_logo_menu:step2()
      end

    -- If the animation step is not greater than 0.
    elseif animation_step <= 0 then
      -- Start step 1.
      solarus_logo_menu:step1()
      -- Start step 2.
      solarus_logo_menu:step2()
    end

    -- Return true to indicate that the keyboard event was handled.
    return true
  end
end

-- Return the menu to the caller.
return solarus_logo_menu
