local game_meta = sol.main.get_metatable("game")


-- Level and Experience

function game_meta:get_level()

  return self:get_value("current_level")

end


function game_meta:set_level(amount)

  return self:set_value("current_level", amount)

end


function game_meta:add_level(amount)

  return self:set_value("current_level", self:get_level() + amount)

end


function game_meta:get_exp()

  return self:get_value("current_exp")

end


function game_meta:set_exp(amount)

  return self:set_value("current_exp", amount)

end


function game_meta:add_exp(amount)

  return self:set_value("current_exp", self:get_exp() + amount)

end




-- Rupees

function game_meta:get_rupee()

  return self:get_value("current_rupee")

end


function game_meta:get_max_rupee()

  return self:get_value("max_rupee")

end


function game_meta:set_rupee(amount)

  return self:set_value("current_rupee", amount)

end


function game_meta:set_max_rupee(amount)

  return self:set_value("max_rupee", amount)

end


function game_meta:add_rupee(amount)

  return self:set_value("current_rupee", self:get_rupee() + amount)

end


function game_meta:remove_rupee(amount)

  return self:set_value("current_rupee", self:get_rupee() - amount)

end
