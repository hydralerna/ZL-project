-- Initialize block behavior specific to this quest.


-- Include scripts
require("scripts/multi_events")

-- Variables
local block_meta = sol.main.get_metatable("block")


-- Add a custom entity for higher blocks
-- (Avoid overlapping problems with the sword)
function block_meta:on_created()

  local animation = "walking2"
  local sprite = self:get_sprite()
  if sprite:has_animation(animation) then
    local map = self:get_map()
    local sprite_name = sprite:get_animation_set()
    local x, y, layer = self:get_position()
    local width, height = self:get_size()
    local custom_entity = map:create_custom_entity({
      name = "",
      sprite = sprite_name,
      x = x,
      y = y,
      width = width,
      height = 8,
      layer = layer + 1,
      direction = 0,
    })
    local custom_entity_sprite = custom_entity:get_sprite()
    custom_entity_sprite:set_direction(0)
    custom_entity:get_sprite():set_animation(animation)
    function self:on_position_changed(x, y, layer)
      custom_entity:set_position(x, y, layer + 1)
    end
    function self:on_removed()
      custom_entity:remove()
    end
  end
end

-- Add custom entity for a special animation 
-- (e.g. "falling" if the ground below is a hole)
function block_meta:on_moved()
  
  local animations = {hole = "falling", lava = "melting", deep_water = "sinking"}
  local animation = animations[self:get_ground_below()] or "walking"
  local sprite = self:get_sprite()
  if sprite:has_animation(animation) then
    if animation == "walking" then
        return
    else   
      local map = self:get_map()
      local sprite_name = sprite:get_animation_set()
      local x, y, layer = self:get_position()
      local width, height = self:get_size()
      local direction = map:get_hero():get_direction4_to(self)
      local custom_entity = map:create_custom_entity({
        name = "fake_block_" .. animation,
        sprite = sprite_name,
        x = direction == 0 and x + (width / 2) or direction == 2 and x - (width / 2) or x,
        y = direction == 3 and y + 13 or direction == 1 and y - 3 or y,
        width = width,
        height = height,
        layer = layer,
        direction = 0,
      })
      if animation == "melting" or animation == "sinking" then
        sol.timer.start(map, 250, function()
           sol.audio.play_sound("splash")
        end)
      end  
      local custom_entity_sprite = custom_entity:get_sprite()
      custom_entity_sprite:set_direction(0)
      custom_entity:get_sprite():set_animation(animation, function()
        custom_entity:remove()
      end)
    end
  else
    error("\"" .. animation .. "\" animation is missing.")
  end

end

return true
