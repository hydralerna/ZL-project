-- TEST KO for a custom animation "Brandishing" animation
-- "The engine defines and plays animation straight away, so when the state changes it is already too late, as there is no intermediate event like on_brandishing."

local hero_meta = sol.main.get_metatable("hero")

require ("scripts/multi_events")

hero_meta:register_event("on_state_changing", function(hero, state_name, next_state_name)

    if hero:get_sprite("tunic"):get_animation() == "brandish" then
        print("on_state_changing("..state_name..", "..next_state_name..")")
    end
end)

hero_meta:register_event("on_state_changed", function(hero, state_name)

    if hero:get_sprite("tunic"):get_animation() == "brandish" then
        print("on_state_changed("..state_name..")")
    end
end)