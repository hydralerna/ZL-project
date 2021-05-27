-- Defines the elements to put in the HUD
-- and their position on the game screen.

-- You can edit this file to add, remove or move some elements of the HUD.

-- Each HUD element script must provide a method new()
-- that creates the element as a menu.
-- See for example scripts/hud/hearts.

-- Negative x or y coordinates mean to measure from the right or bottom
-- of the screen, respectively.

local hud_config = {


  -- HUD background (top and bottom bars)
  {
    menu_script = "scripts/hud/hud_bg",
    x = 0,
    y = 0,
  },

  -- Hearts meter.
  {
    menu_script = "scripts/hud/hearts",
    x = -90,
    y = 3,
  },

  -- Money counter.
  {
    menu_script = "scripts/hud/money",
    x = 2,
    y = -14,
  },

  -- Rupees counter.
  {
    menu_script = "scripts/hud/rupee",
    x = 42,
    y = -14,
  },

  --Level and Experience Counter
  {
    menu_script = ("scripts/hud/lvl_and_exp"),
    x = 128,
    y = -14,
  },

  -- Pause icon.
  {
    menu_script = "scripts/hud/pause_icon",
    x = 92,
    y = -14,
  },

  -- Chrono counter.
  {
    menu_script = "scripts/hud/chrono",
    x = 87,
    y = 177,
  },

  -- Item icon for slot 1.
  {
    menu_script = "scripts/hud/item_icon",
    x = 0,
    y = 0,
    slot = 1,  -- Item slot (1 or 2).
  },

  -- Item icon for slot 2.
  {
    menu_script = "scripts/hud/item_icon",
    x = 48,
    y = 0,
    slot = 2,  -- Item slot (1 or 2).
  },

  -- Attack icon.
  {
    menu_script = "scripts/hud/attack_icon",
    x = 24,
    y = 0,
    dialog_x = 64,
    dialog_y = 64,
  },

  -- Action icon.
  {
    menu_script = "scripts/hud/action_icon",
    x = 92,
    y = 178,
    dialog_x = 64,
    dialog_y = 64,
  },
}

return hud_config
