local index_palette_shader = {}
local info_manager = require("scripts/info_manager")


function index_palette_shader:set_palette(dst)
  local filename = "palette.dat"
  local shift = info_manager:get_value_in_file(filename, "shift")
  local screenScale = info_manager:get_value_in_file(filename, "screenScale")
  local palette_img = sol.surface.create("shaders/palette.png", false)
  local shader = sol.shader.create("index_palette_shader")
  shader:set_uniform("shift", shift)
  shader:set_uniform("screenScale", screenScale)
  shader:set_uniform("palette", palette_img)
  if dst == nil then
    sol.video.set_shader(shader)
  else
    dst:set_shader(shader)
  end
end

return index_palette_shader