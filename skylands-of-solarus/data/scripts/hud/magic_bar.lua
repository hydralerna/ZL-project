-- Magic bar used in game screen and in the savegames selection screen.

local magic_bar_builder = {}


function magic_bar_builder:new(game, config)

  local magic_bar = {}

  if config ~= nil then
    magic_bar.dst_x, magic_bar.dst_y = config.x, config.y
  end

  magic_bar.surface = sol.surface.create(104, 8)
  magic_bar.magic_bar_img = sol.surface.create("hud/magic_bar.png")
  magic_bar.star_sprite = sol.sprite.create("hud/magic_bar_star_light")
  magic_bar.shine = false
  magic_bar.x_shine = 0
  magic_bar.nb_max_magic_displayed = game:get_max_magic()
  magic_bar.nb_current_magic_displayed = game:get_magic()



  function magic_bar:on_started()

    magic_bar.nb_current_magic_displayed = game:get_magic()
    magic_bar:check()
    magic_bar:rebuild_surface()
  end

  -- Checks whether the magic bar displays the correct info
  -- and updates it if necessary.
  function magic_bar:check()

    local need_rebuild = false

    -- Maximum magic.
    local nb_max_magic = game:get_max_magic()
    if nb_max_magic ~= magic_bar.nb_max_magic_displayed then
      need_rebuild = true
      if nb_max_magic < magic_bar.nb_max_magic_displayed then
        -- Decrease immediately if the max magic is reduced.
        magic_bar.nb_current_magic_displayed = game:get_magic()
      end
      magic_bar.nb_max_magic_displayed = nb_max_magic
    end

    -- Current magic.
    local nb_current_magic = game:get_magic()
    if nb_current_magic ~= magic_bar.nb_current_magic_displayed then

      need_rebuild = true
      if nb_current_magic < magic_bar.nb_current_magic_displayed then
        magic_bar.nb_current_magic_displayed = magic_bar.nb_current_magic_displayed - 1
      else
        magic_bar.nb_current_magic_displayed = magic_bar.nb_current_magic_displayed + 1
      end
    end

    -- If we are in-game, play an animation if the magic is high.
    if game:is_started() then
      if game:get_magic() == game:get_max_magic() and not game:is_suspended() then
        need_rebuild = true
        if magic_bar.shine == false and magic_bar.x_shine == 0 then
          magic_bar.shine = true
        end
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      magic_bar:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(magic_bar, 50, function()
      magic_bar:check()
    end)
  end


  function magic_bar:rebuild_surface()

    magic_bar.surface:clear()
    -- magic_bar.surface:fill_color({255, 255, 255})
    local y = 0
    local last_max_x = (magic_bar.nb_max_magic_displayed - 16) / 4
    local last_x = (magic_bar.nb_current_magic_displayed - 16) / 4

    -- Display the magic bar.
    for i = 0, (magic_bar.nb_max_magic_displayed / 16) - 1 do

      local x = (i % (magic_bar.nb_max_magic_displayed / 16)) * 4
      
      -- Background of the magic bar.
      local width = (x == 0 and 6) or (x == last_max_x and 6) or 4
      local offset = (x == 0 and 0) or 2
      local ox = (magic_bar.nb_current_magic_displayed == magic_bar.nb_max_magic_displayed and 80) or 0
      local oy = (x == 0 and 0) or (x == last_max_x and 16) or 8
      -- Special background if there is a maximum of 16 points.
      if magic_bar.nb_max_magic_displayed == 16 then
        width = 8
        oy = 24
      end
      magic_bar.magic_bar_img:draw_region(ox, oy, width, 8, magic_bar.surface, x + offset, y)

      oy = (magic_bar.nb_max_magic_displayed == 16 and 0) or oy
      if i < math.floor(magic_bar.nb_current_magic_displayed / 16) then
        -- This part of the magic bar is full.
        local current_x = (magic_bar.nb_current_magic_displayed - 16) / 4
        ox = (((x == current_x and x ~= last_max_x) or (math.floor(last_x % 4) == 0 and x == math.floor(last_x) and x ~= last_max_x) or (magic_bar.nb_max_magic_displayed == 16)) and 66) or 70
        magic_bar.magic_bar_img:draw_region(ox, oy, 4, 8, magic_bar.surface, x + 2, y)
      end
    end

    -- Last fraction of magic bar.
    local i = math.floor(magic_bar.nb_current_magic_displayed / 16)
    local remaining_fraction = magic_bar.nb_current_magic_displayed % 16
    if remaining_fraction ~= 0 then
      local x = (i % (magic_bar.nb_max_magic_displayed / 16)) * 4
      local ox = (remaining_fraction * 4) + 2
      local oy = (x == 0 and 0) or 8
      magic_bar.magic_bar_img:draw_region(ox, oy, 4, 8, magic_bar.surface, x + 2, y)
    end

    -- Shine effect
    if magic_bar.nb_current_magic_displayed == magic_bar.nb_max_magic_displayed
     and magic_bar.shine == true then
      while magic_bar.x_shine <= last_max_x do
        local oy = (magic_bar.x_shine == 0 and 0) or (magic_bar.x_shine == last_max_x and 16) or 8
        local width = (magic_bar.x_shine == last_max_x and 6) or 4
        magic_bar.magic_bar_img:draw_region(74, oy, width, 8, magic_bar.surface, magic_bar.x_shine + 2, y)
        magic_bar.x_shine = magic_bar.x_shine + 4
        return
      end
    magic_bar.star_sprite:draw(magic_bar.surface, last_max_x + 5, 2)
    elseif magic_bar.nb_current_magic_displayed ~= magic_bar.nb_max_magic_displayed
     and magic_bar.shine == true and magic_bar.x_shine ~= 0 then
      magic_bar.x_shine = 0
    end

  end


  function magic_bar:set_dst_position(x, y)

    magic_bar.dst_x = x
    magic_bar.dst_y = y
  end


  function magic_bar:get_surface()

    return magic_bar.surface
  end


  function magic_bar:on_draw(dst_surface)

    local x, y = magic_bar.dst_x, magic_bar.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    -- Everything was already drawn on self.surface.
    magic_bar.surface:draw(dst_surface, x, y)
  end

  magic_bar:rebuild_surface()

  return magic_bar
end

return magic_bar_builder
