local lighting_manager = {}

--Config:
local need_lantern_to_light_up = true --set this to false if you don't want to require an item to light the area around the hero
local lantern_item = "gear/lantern"
local hero_aura_threshold = 450 --how dark it must be before hero aura is applied- sum of RGB values in darkness level

local effect_sprites = {
  torch0 = sol.sprite.create"entities/effects/light_torch",
  torch1 = sol.sprite.create"entities/effects/light_torch",
  torch2 = sol.sprite.create"entities/effects/light_torch",
  torch3 = sol.sprite.create"entities/effects/light_torch",
  torch4 = sol.sprite.create"entities/effects/light_torch",
  candle = sol.sprite.create"entities/effects/light_s",
  entrance = sol.sprite.create"entities/effects/light_entrance",
  explosion = sol.sprite.create"entities/effects/light_explosion",
  bomb = sol.sprite.create"entities/effects/light_bomb",
  hero_auras = { --each corresponds with a variant of the lantern_item, if need_lantern_to_light_up is true
    sol.sprite.create"entities/effects/hero_aura",
    sol.sprite.create"entities/effects/hero_aura", --TODO
    sol.sprite.create"entities/effects/hero_aura", --TODO
  },
  lantern = sol.sprite.create"entities/effects/light_l",
}
--add color to effects
effect_sprites.torch0:set_color_modulation{255, 230, 150}
effect_sprites.torch1:set_color_modulation{255, 230, 150}
effect_sprites.torch2:set_color_modulation{255, 230, 150}
effect_sprites.torch3:set_color_modulation{255, 230, 150}
effect_sprites.torch4:set_color_modulation{255, 230, 150}
effect_sprites.candle:set_color_modulation{255, 230, 130}
effect_sprites.entrance:set_color_modulation{255, 230, 130}
for k, sprite in pairs(effect_sprites.hero_auras) do
  -- sprite:set_color_modulation{215, 190, 140}
  sprite:set_color_modulation{255, 230, 150}
end
effect_sprites.lantern:set_color_modulation{230, 210, 240}
-- effect_sprites.explosion:set_color_modulation{255, 240, 180}
effect_sprites.explosion:set_color_modulation{255, 230, 130}
effect_sprites.bomb:set_color_modulation{255, 230, 130}

--set blend modes
for i=1, #effect_sprites do
  effect_sprites[i]:set_blend_mode"blend"
end

--create surfaces
local shadow_surface
local light_surface
local darkness_color
shadow_surface = sol.surface.create()
shadow_surface:set_blend_mode"multiply"
light_surface = sol.surface.create()
light_surface:set_blend_mode"add"
darkness_color = {255,255,255} --default darkness level

--Getters
function lighting_manager:get_light_surface()
  return light_surface
end

function lighting_manager:get_shadow_surface()
  return shadow_surface
end

function lighting_manager:get_darkness_level()
  return darkness_color
end

function lighting_manager:get_effect_sprites()
  return effect_sprites
end



--Preset darkness levels / colors
function get_darkness_color_from_level(level)
  local color
  if level == 0 then
    color = {255,255,255}
  elseif level == 1 then
    color = {150,180,200}
  elseif level == 2 then
    color = {100,115,135}
  elseif level == 3 then
    color = {75,85,90}
  elseif level == 4 then
    color = {20,40,55}
  elseif level == 5 then
    color = {5, 15, 25}
  elseif level == 6 then
    color = {0, 0, 0}
  elseif level == "day" then
    color = {255,250,245}
  elseif level == "evening" then
    color = {240,230,180}
  elseif level == "sunset" then
    color = {255,200,130}
  elseif level == "dusk" then
    color = {170,160,140}
  elseif level == "night" then
    color = {100,115,135}
  elseif level == "dawn" then
    color = {200,200,255}
  elseif level == "morning" then
    color = {240,240,255}
  elseif level == "desert" then
    color = {255, 240, 210}
  else
    color = level
  end

  return color
end




function lighting_manager:set_darkness_level(level)
  local game = sol.main.get_game()
  local hero = game:get_hero()
  --Always fade to new level. This function just sets hero lighting aura also. Could combine these.
  lighting_manager:fade_to_darkness_level(level)

  darkness_color = get_darkness_color_from_level(level)
  local light_sum = darkness_color[1] + darkness_color[2] + darkness_color[3]
  if (light_sum <= hero_aura_threshold) then
    if (need_lantern_to_light_up and game:has_item(lantern_item)) then
      hero.lighting_aura = game:get_item(lantern_item):get_variant()
    else
      hero.lighting_aura = false
    end
  else
    hero.lighting_aura = false
  end
end


function lighting_manager:fade_to_darkness_level(level, fade_speed)
  if lighting_manager.color_fade_timer then lighting_manager.color_fade_timer:stop() end
  new_darkness_color = get_darkness_color_from_level(level)

  local r1, g1, b1 = darkness_color[1], darkness_color[2], darkness_color[3]
  local r2, g2, b2 = new_darkness_color[1], new_darkness_color[2], new_darkness_color[3]

  lighting_manager.color_fade_timer = sol.timer.start(sol.main.get_game(), fade_speed or 10, function()
    local r_step = 1
    local g_step = 1
    local b_step = 1
    if math.abs(r1-r2) >= 10 then r_step = 5 end
    if math.abs(g1-g2) >= 10 then g_step = 5 end
    if math.abs(b1-b2) >= 10 then b_step = 5 end
    if r1 > r2 then r_step = r_step * -1 elseif r1 == r2 then r_step = 0 end
    if g1 > g2 then g_step = g_step * -1 elseif g1 == g2 then g_step = 0 end
    if b1 > b2 then b_step = b_step * -1 elseif b1 == b2 then b_step = 0 end
    r1 = r1 + r_step
    g1 = g1 + g_step
    b1 = b1 + b_step    
    darkness_color = {r1, g1, b1}
    if r1 == r2 and g1 == g2 and b1 == b2 then
    else return true
    end
  end)
end


function lighting_manager:on_draw(dst_surface)
  local game = sol.main.get_game()
  local map = game:get_map()
  local hero = map:get_hero()
  local cam_x, cam_y = map:get_camera():get_position()
  local hx, hy, hz = hero:get_position()

  --clear the surfaces
  light_surface:clear()
  shadow_surface:clear()
  --color surfaces
  shadow_surface:fill_color(darkness_color)

  --draw different light effects
  --hero aura:
  if hero.lighting_aura then
    local life = game:get_life()
    if life >= 2 and life < 80 then
      effect_sprites.hero_auras[hero.lighting_aura]:set_direction(math.ceil(life / 2))
    elseif life == 1 then
      effect_sprites.hero_auras[hero.lighting_aura]:set_direction(0)
    else
      effect_sprites.hero_auras[hero.lighting_aura]:set_direction(41)
    end
    effect_sprites.hero_auras[hero.lighting_aura]:draw(light_surface, hx - cam_x, hy - cam_y)
  end
  --static light sources
  if map.static_light_sources then
    for _, source in pairs(map.static_light_sources) do
      source.sprite:draw(light_surface, source.x - cam_x, source.y - cam_y)
    end
  end
  --dynamic light sources
  if map.dynamic_light_sources then
    for _, source in pairs(map.dynamic_light_sources) do
      local x, y, z = source.entity:get_position()
      source.sprite:draw(light_surface, x - cam_x, y - cam_y)
    end
  end


  light_surface:draw(shadow_surface)
  shadow_surface:draw(dst_surface)
end


return lighting_manager
