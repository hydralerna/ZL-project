-- The counter of coins shown in the game screen.

local text_fx_helper = require("scripts/text_fx_helper")

local coins_builder = {}

function coins_builder:new(game, config)

  local coins = {}

  coins.dst_x, coins.dst_y = config.x, config.y
  coins.surface = sol.surface.create(32, 14)
  coins.text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "enter_command",
    color = {48, 111, 80},
    font_size = 16,
  })
  coins.font_fx_color = {143, 192, 112}
  coins.text_surface:set_text(game:get_money())
  coins.coin_icons_img = sol.surface.create("hud/coin_icon.png")
  coins.coin_bag_displayed = game:get_item("coin_bag"):get_variant()
  coins.amount_displayed = game:get_money()

  function coins:check()

    local need_rebuild = false
    local coin_bag = game:get_item("coin_bag"):get_variant()
    local amount = game:get_money()

    -- Max coins.
    if coin_bag ~= coins.coin_bag_displayed then
      need_rebuild = true
      coins.coin_bag_displayed = coin_bag
    end

    -- Current amount of coins.
    if amount ~= coins.amount_displayed then
      need_rebuild = true
      local increment
      if amount > coins.amount_displayed then
        increment = 1
      else
        increment = -1
      end
      coins.amount_displayed = coins.amount_displayed + increment

      -- Play a sound if we have just reached the final value.
      if coins.amount_displayed == amount then
        sol.audio.play_sound("items/get_rupee")

      -- While the counter is scrolling, play a sound every 3 values.
      elseif coins.amount_displayed % 3 == 0 then
        sol.audio.play_sound("items/get_rupee")
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      coins:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(coins, 40, function()
      coins:check()
    end)
  end


  function coins:rebuild_surface()

    coins.surface:clear()
    -- Max coin (icon).
    coins.coin_icons_img:draw_region(0, 0, 10, 11, coins.surface, 0, 1)
    -- Current coin (counter).
    local max_amount = game:get_max_money()
    coins.text_surface:set_text(coins.amount_displayed)
    coins.text_surface:set_xy(13, 6)
    if coins.amount_displayed == max_amount then
      text_fx_helper:draw_text_with_stroke(coins.surface, coins.text_surface, coins.font_fx_color)
    else
      text_fx_helper:draw_text_with_shadow(coins.surface, coins.text_surface, coins.font_fx_color)
    end
  end


  function coins:get_surface()

    return coins.surface
  end


  function coins:on_draw(dst_surface)

    local x, y = coins.dst_x, coins.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end
    coins.surface:draw(dst_surface, x, y)
  end


  function coins:on_started()

    coins:check()
    coins:rebuild_surface()
  end

  return coins
end

return coins_builder
