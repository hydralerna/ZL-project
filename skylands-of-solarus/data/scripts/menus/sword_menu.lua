-- WIP

local game_manager = require("scripts/game_manager")
local index_palette_shader = require("scripts/index_palette_shader")
local info_manager = require("scripts/info_manager")

local sword_menu = {}


-- Resets the timer.
function sword_menu:reset_timer()

  if self.timer ~= nil then
    self.timer:stop()
    self.timer = nil
  end
end

-- Called when the menu is started.
function sword_menu:on_started()

  self:reset_timer()
  self.surface_w, self.surface_h = sol.video.get_quest_size()
  self.bg_surface = sol.surface.create(self.surface_w, self.surface_h)
  self.bg_surface:fill_color({0, 0, 0, 255})
  self.sword_sprite = sol.sprite.create("menus/title_screen/sword")
  self.sword_sprite:set_animation("appearing", function()
  self.sword_sprite:set_animation("static")
	 self.timer = sol.timer.start(1000, function()
        sol.menu.stop(sword_menu)
  	end)
  end)
  index_palette_shader:set_palette()
end


function sword_menu:on_draw(dst_surface)

  self.bg_surface:draw(dst_surface, 0, 0)
  self.sword_sprite:draw_region(-24, -16, 48, 100, dst_surface, 104, 64)
end


function sword_menu:on_finished()

  index_palette_shader:set_palette()
end

return sword_menu