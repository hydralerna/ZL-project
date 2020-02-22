local info_manager = {}


-- Function to read a line in a sol.file (by Zefk)
-- Source: http://forum.solarus-games.org/index.php/topic,815.msg5399.html#msg5399
local function readLines(sPath)
  local file = sol.file.open(sPath, "r")
  if file then
        local tLines = {}
        local sLine = file:read()
        while sLine do
          table.insert(tLines, sLine)
          sLine = file:read()
        end
        file:close()
        return tLines
  end
  return nil
end


-- Function to write a line in a sol.file (by Zefk)
-- Source: http://forum.solarus-games.org/index.php/topic,815.msg5399.html#msg5399
local function writeLines(sPath, tLines)
  local file = sol.file.open(sPath, "w")
  if file then
        for _, sLine in ipairs(tLines) do
          file:write(sLine, "\n")
        end
        file:close()
  end
 -- for k, v in pairs(tLines) do
  --  file:write(k .. " = " .. v .. "\n")
  --  file:close()
  --end
end


-- Function to add double quote characters to a given string
function info_manager:quote(str)
    return '"'..str..'"'
end


-- Function to get a value in a sol.file
function info_manager:get_value_in_file(sPath, id)
	if sol.file.exists(sPath) then
		local file = sol.file.open(sPath, "r")
		local sLine = file:read()
		while sLine do
      if (sLine:match("(.+) =") == id) then
        v = sLine:match("= (.+)$")
			end
			sLine = file:read()
		end
		file:close()
	end
	return v
end


-- Function to set a value in a sol.file
function info_manager:set_value_in_file(sPath, id, value)
	if sol.file.exists(sPath) then
    local isFound = false
    if type(value) == "string" then
      value = info_manager:quote(value)
    elseif type(value) == "number" then
        value = tostring(value):gsub("%,","%.")
    elseif type(value) == "boolean" then
      value = info_manager:quote(tostring(value))
    end
    local tLines = readLines(sPath)
    for k, sLine in ipairs(tLines) do
        if (sLine:match("(.+) =") == id) then
          local v = sLine:gsub(sLine:match("= (.+)$"), value)
          tLines[k] = v
          isFound = true
        end
    end
    if isFound then
      writeLines(sPath, tLines)
    end
	end
end


-- Function to create the sol.file and add lines from an array
function info_manager:create_sol_file(sPath, tbl)
  if sol.file.exists(sPath) == false then
    if type(tbl) == "table" then
      local file = sol.file.open(sPath, "w")
      for id, value in pairs(tbl) do
        if type(value) == "string" then
          value = info_manager:quote(value)
        elseif type(value) == "number" then
          value = tostring(value):gsub("%,","%.")
        elseif type(value) == "boolean" then
          value = tostring(value)
        end
        file:write(id, " = ", value, "\n")
      end
      file:close()
    end
  end
end


return info_manager

