-- Defines the elements to put in the HUD
-- and their position on the game screen.

-- You can edit this file to add, remove or move some elements of the HUD.

-- Each HUD element script must provide a method new()
-- that creates the element as a menu.
-- See for example scripts/hud/hearts.

-- Negative x or y coordinates mean to measure from the right or bottom
-- of the screen, respectively.

local x_offset = 68

local hud_config = {

  -- HUD menu (left and right)
  {
    menu_script = "scripts/hud/hud_menu",
    x = 0,
    y = 0,
  },


  -- HUD background (top and bottom bars)
  {
    menu_script = "scripts/hud/hud_bg",
    x = 0,
    y = 0,
  },

  -- Hearts meter.
  {
    menu_script = "scripts/hud/hearts",
    x = -177,
    y = 8,
  },

  -- Hearts meter for the enemy
  {
    menu_script = "scripts/hud/hearts_enemy",
    x = -177,
    y = 24,
  },


  -- Money counter.
  {
    menu_script = "scripts/hud/money",
    x = 90,
    y = -14,
  },

  -- Rupees counter.
  {
    menu_script = "scripts/hud/rupee",
    x = 130,
    y = -14,
  },

  --Level and Experience Counter
  {
    menu_script = ("scripts/hud/lvl_and_exp"),
    x = 216,
    y = -14,
  },

  -- Pause icon.
  {
    menu_script = "scripts/hud/pause_icon",
    x = x_offset + 12,
    y = 2,
  },

  -- Chrono counter.
  --{
  --  menu_script = "scripts/hud/chrono",
   -- x = 87,
   -- y = 177,
  --},

  -- Item icon for slot 1.
  {
    menu_script = "scripts/hud/item_icon",
    x = x_offset,
    y = 20,
    slot = 1,  -- Item slot (1 or 2).
  },

  -- Item icon for slot 2.
  {
    menu_script = "scripts/hud/item_icon",
    x = x_offset + 48,
    y = 20,
    slot = 2,  -- Item slot (1 or 2).
  },

  -- Attack icon.
  {
    menu_script = "scripts/hud/attack_icon",
    x = x_offset + 24,
    y = 20,
    dialog_x = x_offset + 24,
    dialog_y = 20,
  },

  -- Action icon.
  {
    menu_script = "scripts/hud/action_icon",
    x = x_offset + 48,
    y = 2,
    dialog_x = x_offset + 48,
    dialog_y = 2,
  },
}

return hud_config
