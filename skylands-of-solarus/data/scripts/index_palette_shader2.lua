local index_palette_shader2 = {}
local info_manager = require("scripts/info_manager")


function index_palette_shader2:set_palette(dst)
  local filename = "palette2.dat"
  local palette_size = info_manager:get_value_in_file(filename, "palette_size")
  local palette_colors = info_manager:get_value_in_file(filename, "palette_colors")
  local palette_img = sol.surface.create("shaders/palette2.png", false)
  local shader = sol.shader.create("index_palette_shader2")
  shader:set_uniform("palette_size", palette_size)
  shader:set_uniform("palette_colors", palette_colors)
  shader:set_uniform("palette", palette_img)
  if dst == nil then
    sol.video.set_shader(shader)
  else
    dst:set_shader(shader)
  end
end

return index_palette_shader2