-- util.lua
-- version 0.1a1
-- 12 Jan 2019
-- GNU General Public License Version 3
-- author: Llamazing
 
--  	   __   __   __   __  _____   _____________  _______
--  	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
--  	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
--  	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
--  
--  	This utility script draws lines between two points and handles coordinate conversions.


local util = {}

function util.map_to_quest_coords(x, y)
	local game = sol.main.get_game()
	if not game then return end
	
	local map = game:get_map()
	if not map then return end
	
	local map_width, map_height = map:get_size()
	local quest_width, quest_height = sol.video.get_quest_size()
	
	--TODO
end

function util.quest_to_map_coords(x, y)
	local game = sol.main.get_game()
	if not game then return end
	
	local map = game:get_map()
	if not map then return end
	
	local map_width, map_height = map:get_size()
	local quest_width, quest_height = sol.video.get_quest_size()
	
	--TODO
end

function util.make_path(coords1, coords2)
	local path = {}
	
	local x_lower, x_upper, y_start, y_stop
	if coords1.x < coords2.x then
		x_lower, x_upper = coords1.x, coords2.x
		y_start, y_stop = coords1.y, coords2.y
	else
		x_lower, x_upper = coords2.x, coords1.x
		y_start, y_stop = coords2.y, coords1.y
	end
	
	local dx = x_upper - x_lower
	local dy = y_stop - y_start
	
	--calculate function for path of connecting line
	if dx ~= 0 then
		if dy ~= 0 then
			local m = dy/dx --slope, nil when vertical
			
			local y_inc --is +1 for positive slope, -1 for negative slope
			if m>0 then
				y_inc = 1
			else y_inc = -1 end
			
			local y_prev = y_start --keep track of what the previous y coordinate was
			path[y_start] = {start = x_lower, stop = x_lower} --create first entry at starting node
			
			for x = x_lower+1, x_upper do
				y = m*(x - x_lower - 0.5) + y_start + 0.5 --equation for line through center of nodes
				y = math.floor(y)
				
				if y ~= y_prev then
					for y_skipped = y_prev + y_inc, y - y_inc, y_inc do --for the rows in between prev and this one, may be none
						path[y_skipped] = {start = x - 1, stop = x - 1} --create new entry for each skipped row
					end
					
					path[y] = {start = x - 1, stop = x} --create new entry for this row
					y_prev = y --update with current row
				else path[y].stop = x end 
			end
			
			if not path[y_stop] then path[y_stop] = {start = x_upper} end --create new entry if doesn't already exist
			path[y_stop].stop = x_upper --final entry for ending node
			
			for y_skipped = y_prev + y_inc, y_stop - y_inc, y_inc do --for the rows in between prev and this one, may be none
				path[y_skipped] = {start = x_upper, stop = x_upper} --create new entry for each skipped row
			end
		else path[y_start] = {start = x_lower, stop = x_upper} end --draw horizontal line
	else --draw vertical line
		for y = y_start, y_stop, y_start<y_stop and 1 or -1 do
			path[y] = {start = x_lower, stop = x_lower} --create new entry for each row, x_lower & x_upper are equal
		end
	end
	
	return path
end

return util

-- Copyright 2019 Llamazing
 
-- This program is free software: you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software Foundation,
-- either version 3 of the License, or (at your option) any later version.
-- 
-- It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with this
-- program.  If not, see <http://www.gnu.org/licenses/>.
