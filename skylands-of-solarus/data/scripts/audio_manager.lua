-- Copyright (C) 2018 Christopho, Solarus - http://www.solarus-games.org
--
-- Solarus Quest Editor is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Solarus Quest Editor is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program. If not, see <http://www.gnu.org/licenses/>.

-- Variables
local audio_manager = {}
local music_fade_timer
local initial_volume = sol.audio.get_music_volume()
local next_music

-- Include scripts
require("scripts/multi_events")

function audio_manager:play_music_fade(context, music)

  if music_fade_timer == nil and
  music == sol.audio.get_music() then
    -- No fade in progress and no music change: nothing to do.
    return
  end

  if music_fade_timer ~= nil then
    if music == next_music then
      -- Fade in progress but already planning to put the wanted music:
      -- nothing to do.
      return
    end

    -- Fade in progress but with another music target.
    -- Cancel the first fade.
    sol.audio.set_music_volume(initial_volume)
    music_fade_timer:stop()
  end

  local initial_music = sol.audio.get_music()
  next_music = music
  initial_volume = sol.audio.get_music_volume()
  local volume = initial_volume
  local step = initial_volume / 10
  local changed = false

  context:register_event("on_finished", function()
      -- Just in case the map is changed or the game is closed
      -- during the fade.
      if music_fade_timer ~= nil and music_fade_timer:get_remaining_time() > 0 then
        sol.audio.set_music_volume(initial_volume)
      end
    end)

  music_fade_timer = sol.timer.start(context, 100, function()

      if not changed then
        if sol.audio.get_music() ~= initial_music then
          -- Another music was set in the meantime.
          sol.audio.set_music_volume(initial_volume)
          return false
        end

        volume = math.max(0, volume - step)
        sol.audio.set_music_volume(volume)
        if volume <= 0 then
          audio_manager:play_music(music)
          changed = true
        end
        return true
      end

      if sol.audio.get_music() ~= music then
        -- Another music was set in the meantime.
        sol.audio.set_music_volume(initial_volume)
        return false
      end

      volume = math.min(initial_volume, volume + step)
      sol.audio.set_music_volume(volume)

      return volume < initial_volume
    end)

  music_fade_timer:set_suspended_with_map(false)

end

-- Get current sounds and musics directory
function audio_manager:get_directory()

  local game = sol.main.get_game()
  local mode = (game ~= nil) and game:get_value("mode") or "snes"
  local directory = (mode == "gb") and "gb" or "gb" -- Todo Force GB musics

  return directory

end

-- sol.audio.play_music() equivalent, warn instead of error when playing not existing music
local function lenient_play_music(id_music)

  if sol.file.exists("musics/" .. id_music .. ".ogg") or sol.file.exists("musics/" .. id_music .. ".it") or sol.file.exists("musics/" .. id_music .. ".spc") then
    sol.audio.play_music(id_music)
  else
    print("Warning : the music " .. id_music .. " doesn't exist")
  end

end

-- Play music according to the mode of play
function audio_manager:play_music(id_music)

  if id_music == nil then
    return false
  end
  local directory = audio_manager:get_directory()
  local game = sol.main.get_game()
  if game ~= nil and game.hero_charm then
    game.id_music = directory .. '/' ..id_music
    id_music = '17_adrenaline_rush'
  end
  lenient_play_music(directory .. "/" .. id_music)

end

function audio_manager:stop_music()

  sol.audio.stop_music()

end

-- Refresh music according to the mode of play
function audio_manager:refresh_music()

  local id_music = sol.audio.get_music()
  local directory = audio_manager:get_directory()
  
  local game = sol.main.get_game()

  if game == nil then
    return
  end

  if game.hero_charm then
    if id_music ~= 'snes/17_adrenaline_rush' then
      game.id_music = id_music
      id_music = 'snes/17_adrenaline_rush'
    end
  else
    if game.id_music then
      id_music = game.id_music
      game.id_music = nil
    end
  end
  if id_music then
    if directory == "gb" then
      id_music = id_music:gsub("snes/", "gb/")
    else
      id_music = id_music:gsub("gb/", "snes/")
    end
    lenient_play_music(id_music)
  end

end

-- Play sound according to the mode of play
function audio_manager:play_sound(id_sound)

  if id_sound == nil then
    return false
  end
  id_sound = audio_manager:get_directory() .. "/" .. id_sound
  if sol.file.exists("sounds/" .. id_sound .. ".ogg") then
    sol.audio.play_sound(id_sound)
  else
    print("Warning: the sound " .. id_sound .. " doesn't exist.")
  end

end

-- Play sptial sound relative to en entity according to the mode of play and distance of the map hero from said entity
function audio_manager:play_entity_sound(entity, id_sound, max_distance)

  if id_sound == nil or entity == nil then
    return false
  end
  max_distance=max_distance or 255
  id_sound = audio_manager:get_directory() .. "/" .. id_sound
  local hero=entity:get_map():get_hero()
  if entity:get_distance(hero) <= max_distance then
    if sol.file.exists("sounds/" .. id_sound .. ".ogg") then
      sol.audio.play_sound(id_sound)
    else
      print("Warning: the sound " .. id_sound .. " doesn't exist.")
    end
  end

end

return audio_manager
