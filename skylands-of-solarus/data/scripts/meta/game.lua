local game_meta = sol.main.get_metatable("game")


-- Level and Experience

function game_meta:get_level()
  return self:get_value("current_level")
end

function game_meta:set_level(level)
  return self:set_value("current_level", level)
end

function game_meta:add_level(level)
  local level = level
  local c_level = self:get_level()
  local level_up = c_level + level
  return self:set_value("current_level", level_up)
end

function game_meta:get_exp()
  return self:get_value("current_exp")
end

function game_meta:set_exp(exp)
  return self:set_value("current_exp", exp)
end

function game_meta:add_exp(exp)
  local exp = exp
  local c_exp = self:get_exp()
  local exp_up = c_exp + exp
  return self:set_value("current_exp", exp_up)
end



-- Rupees

function game_meta:get_rupee()
  return self:get_value("current_rupee")
end

function game_meta:get_max_rupee()
  return self:get_value("max_rupee")
end

function game_meta:set_rupee(rupee)
  return self:set_value("current_rupee", rupee)
end

function game_meta:set_max_rupee(rupee)
  return self:set_value("max_rupee", rupee)
end

function game_meta:add_rupee(rupee)
  local rupee = rupee
  local c_rupee = self:get_rupee()
  local rupee_up = c_rupee + rupee
  return self:set_value("current_rupee", rupee_up)
end

function game_meta:remove_rupee(rupee)
  local rupee = rupee
  local c_rupee = self:get_rupee()
  local rupee_up = c_rupee - rupee
  return self:set_value("current_rupee", rupee_up)
end