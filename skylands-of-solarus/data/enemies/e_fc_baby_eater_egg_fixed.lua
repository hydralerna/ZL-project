local enemy = ...

-- Minillosaur waiting in eggs for the hero to drop by.

require("enemies/generic_waiting_for_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/e_fc_baby_eater_egg_fixed",
  life = 4,
  damage = 2,
  normal_speed = 16,
  faster_speed = 24,
  hurt_style = "normal",
  push_hero_on_sword = false,
  pushed_when_hurt = true,
  asleep_animation = "egg",
  awaking_animation = "egg_breaking",
  normal_animation = "walking",
  obstacle_behavior = "flying",
  awakening_sound = "stone"
})

