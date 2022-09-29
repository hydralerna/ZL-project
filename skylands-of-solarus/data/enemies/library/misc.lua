-- Function to wall like a crab (d8 means direction8)
function crab(d8)

  local d4 = 0 -- direction4
  local a = 0  -- angle
  if d8 == 2 or d8 == 6 then
    local tbl = {0, 2}
    d4 = tbl[math.random(#tbl)]
    if d4 == 2 then
      a = math.pi
    end
  elseif d8 >= 3 and d8 <= 5 then
     d4 = 2
     a = math.pi
  end
  return d4, a
end
