local manager = {}

local lighting_manager = require"scripts/fx/lighting/lighting_manager"
local effect_sprites = lighting_manager:get_effect_sprites()

function manager:create_light_source(entity)
  local type = entity:get_type()
  local source = {entity = entity}
  if entity.light_source_sprite then
    assert(type(entity.light_source_sprite) == "string", "entity.light_source sprite must be a string")
    source.sprite = sol.sprite.create(entity.light_source_sprite)
  elseif type == "explosion" then
    source.sprite = effect_sprites.explosion
  elseif type == "fire" then
    source.sprite = effect_sprites.torch4
  elseif type == "bomb" then
    source.sprite = effect_sprites.bomb
  elseif type == "carried_object" then
    local animation_set = entity:get_sprite():get_animation_set()
    if animation_set == "entities/bomb" then
      source.sprite = effect_sprites.bomb
    end
  --elseif type == "destructible" then
  --  source.sprite = effect_sprites.bomb
    --print(entity:get_property("type"))
  elseif type == "custom_entity" then
    local model = entity:get_model()
    if model:match("elements/flame") then
      source.sprite = effect_sprites.torch4
    elseif string.match(model, "elements/lightning") then
      source.sprite = effect_sprites.torch4
    elseif string.match(model, "elements/smolder") then
      source.sprite = effect_sprites.candle
    --elseif model:match("world_objects/treasure_glow") then
    --  source.sprite = effect_sprites.candle
    elseif model:match("world_objects/treasure_glow") then
      source.sprite = effect_sprites.torch4
    end
  elseif type == "enemy" then
    if entity.lighting_effect == 1 then
      source.sprite = effect_sprites.candle
    elseif entity.lighting_effect then
      source.sprite = effect_sprites.torch4
    end
  end

  return source
end

return manager