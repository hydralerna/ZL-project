local info_manager = {}

local serpent = require"scripts/utility/serpent"  -- Source: https://github.com/pkulchenko/serpent/blob/master/src/serpent.lua


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
end


-- Function to sort a hash table by key name
local function sort_hashtable_by_keyname(hashtable)

  if type(hashtable) == "table" then
    local t = {}
    for k, v in pairs(hashtable) do
      table.insert(t , {key = tostring(k), value = v})
    end
    table.sort(t, function (a, b) return a.key < b.key end)
    return t
  end
end


-- Function to add double quote characters to a given string
local function quote(str)

    return '"'..str..'"'
end


-- Function to get a value in a sol.file
function info_manager:get_value_in_file(sPath, key)

  if sol.file.exists(sPath) then
    local file = sol.file.open(sPath, "r")
    local sLine = file:read()
    while sLine do
      if (sLine:match("(.+) =") == key) then
        local value = sLine:match("= (.+)$")
        if type(value) == "string" and (type(tonumber(value)) == "number") then
          return tonumber(value)
        elseif type(value) == "string" and string.match("true" or "false", value) then
          local bool = (value == "true" and true) or false
          return bool
        elseif value:match("^do local") then
          value = value:gsub('\\"', '"')
          local ok, tbl = serpent.load(value)
          if ok then return tbl end
        else
          return value
        end
      end
      sLine = file:read()
    end
    file:close()
  end
end


-- Function to set a value in a sol.file
function info_manager:set_value_in_file(sPath, key, value)

  if sol.file.exists(sPath) then
    local isFound = false
    if type(value) == "string" then
      value = quote(value)
    elseif type(value) == "number" then
      value = tostring(value):gsub("%,","%.")
    elseif type(value) == "boolean" then
      value = tostring(value)
    elseif type(value) == "table" then
      local t = serpent.dump(value)
      t = string.gsub(t, '"', '\\"')
      value = t
    end
    local tLines = readLines(sPath)
    for k, sLine in ipairs(tLines) do
      if (sLine:match("(.+) =") == key) then
        local v = sLine:gsub(sLine:match("= (.+)$"), value)
        tLines[k] = v
        isFound = true
      end
    end
    if not isFound then
      table.insert(tLines, key .. " = " .. value)
    end
    table.sort(tLines)
    writeLines(sPath, tLines)
  end
end


-- Function to remove a key and its value(s) in a sol.file
function info_manager:remove_key_in_file(sPath, key)

  if sol.file.exists(sPath) then
    local isFound = false
    local tLines = readLines(sPath)
    for k, sLine in ipairs(tLines) do
      if (sLine:match("(.+) =") == key) then
        table.remove(tLines, k)
        isFound = true
      end
    end
    if isFound then
      writeLines(sPath, tLines)
    end
  end
end


-- Function to create a sol.file and add lines from an array
function info_manager:create_sol_file(sPath, tbl, bForce)

  if (bForce == nil) then
    bForce = false
  end
  if sol.file.exists(sPath) == false or bForce == true then
    if type(tbl) == "table" then
      tbl = sort_hashtable_by_keyname(tbl)
      local file = sol.file.open(sPath, "w")
      for _, v in pairs(tbl) do
        local key = v.key
        local value = v.value
        if type(value) == "string" then
          value = quote(value)
        elseif type(value) == "number" then
          value = tostring(value):gsub("%,","%.")
        elseif type(value) == "boolean" then
          value = tostring(value)
        elseif type(value) == "table" then
          local t = serpent.dump(value)
          t = string.gsub(t, '"', '\\"')
          value = t
        end
        file:write(key, " = ", value, "\n")
      end
      file:close()
    end
  end
end


-- Function to remove a sol.file

-- Use "sol.file.remove(file_name)"
-- See https://doxygen.solarus-games.org/latest/lua_api_file.html


return info_manager



--[[
-- Usage (by Zefk)
-- Source: http://forum.solarus-games.org/index.php/topic,815.msg5399.html#msg5399

-- Make a text file
local file_make_test = sol.file.open("test.txt", "w")
file_make_test:close()

local tLines = readLines("test.txt") -- Read this file
table.insert(tLines, "This is the first line!\n") -- Line 1
tLines[2] = "This is line 2!\n" -- Line 2
tLines[3] = "This is line 3!\n" -- Line 3
tLines[4] = 50 -- Line 4

table.remove(tLines, 2) -- Remove line 2
writeLines("test.txt", tLines) --Write lines to this file
print("Lines in the file: ", #tLines) --Print number of lines

-- Open file. You must open the file to get the value
local tLines = readLines("test.txt") -- Read this file

-- Print line 3. Line 4 will not be 50 because we removed line 2. That means line 3 will be 50.
print("Line 4 value is: "..tLines[3])
--]]



--[[
-- Usage (by froggy77)
-- Create an array
local tbl_demo = {
  hero_name = "Link",
  level = 8,
  fraction = 10 / 3,
  chance = true,
  line_to_remove = "This message will self-destruct in 5 seconds.",
  fruits = {apple = 8, banana = 3, cherry = 0},
}


-- Create a file and add lines from our array
local file = "demo.dat"
info_manager:create_sol_file(file, tbl_demo, true)  -- true to overwrite the file. false is the default value if you don't specify it. 

-- Content of this new file at this moment
--[[
  chance = true
  fraction = 3.3333333333333
  fruits = do local _={cherry=0,banana=3,apple=8};return _;end
  hero_name = "Link"
  level = 8
  line_to_remove = "This message will self-destruct in 5 seconds."
--]]


--[[
-- Get some values

print(tbl_demo.hero_name)  -- will print  Link
-- Let's anNILhilate^^ our array just for the demo.
tbl_demo = nil
-- So now, we have no choice but to use our file to get the values like hero name.
local hero_name = info_manager:get_value_in_file(file, "hero_name")
print(hero_name)   -- will print  Link

local fraction = info_manager:get_value_in_file(file, "fraction")
print(fraction, type(fraction)) -- will print 3.3333333333333

local fruits = info_manager:get_value_in_file(file, "fruits")
print("Number of apples:", fruits.apple) -- wiil print   Number of apples: 8
-- Example of reading the content of "fruits"
if type(fruits) == "table" then
  for fruit, nb in pairs(fruits) do
    print(fruit, nb)
  end
end
 --[[ It will print:
  cherry 0
  banana 3
  apple 8
--]]


--[[
-- Add entries in our file

info_manager:set_value_in_file(file, "new_key", "Hello world")

tbl_secret_chest = {enable = true, map = "demo_map", name = "Golden chest", position = {x = 128, y = 96, layer = 0}}
info_manager:set_value_in_file(file, "secret_chest", tbl_secret_chest)


-- Replace some values
 
info_manager:set_value_in_file(file, "hero_name", "Lolo")

info_manager:set_value_in_file(file, "chance", false)

local current_level = info_manager:get_value_in_file(file, "level")
info_manager:set_value_in_file(file, "level", current_level + 1)


-- Remove an entry
info_manager:remove_key_in_file(file, "line_to_remove")
--]]

-- Content of the file after our changes
--[[
  chance = false
  fraction = 3.3333333333333
  fruits = do local _={cherry=0,banana=3,apple=8};return _;end
  hero_name = "Lolo"
  level = 9
  new_key = "Hello world"
  secret_chest = do local _={enable=true,position={y=96,x=128,layer=0},name=\"Golden chest\",map=\"demo_map\"};return _;end
--]]