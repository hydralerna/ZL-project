-- Automation made easy with a simple way to handle it.
-- Usage:
-- local automation = require("scripts/automation.lua")
-- local my_automation = automation:new(context, target_entity, "linear", 200, { x = 200, opacity = 92})
-- my_automation.on_finished = function()
--    called_when_finished...
-- end
-- my_automation:start()

local easing = require("scripts/automation/easing")

local automation_builder = {}

function automation_builder:new(context, target_entity, curve_type, duration, end_properties, on_finished)

  -- No automation if incorrect parameters.
  local easing_func = easing[curve_type]
  assert(easing_func ~= nil, "Automation curve type not found:"..curve_type)
  if easing_func == nil then
    return nil
  end

  local begin_x, begin_y = target_entity:get_xy()

  -- Create automation
  local automation = {
    context = context,
    target_entity = target_entity,
    end_properties = end_properties,
    duration = duration,
    curve_type = curve_type,
    on_finished = on_finished,
    -- Internal properties
    begin_properties = {},
    update_delta = 1000/60,
    elapsed_time = 0,
    stopped = true,
    finished = false,
    interrupted = false,
    timer = nil,
    easing_func = easing_func,
  }

  -- Initializes begin_properties.
  function automation:init_properties()
    -- A bit dirty at the moment...
    if automation.end_properties.x or automation.end_properties.y then
      if target_entity.get_xy then
        local current_x, current_y = target_entity:get_xy()
        if automation.end_properties.x then
          automation.begin_properties.x = current_x
        end
        if automation.end_properties.y then
          automation.begin_properties.y = current_y
        end
      end
    end
    if automation.end_properties.opacity then
      if target_entity.get_opacity then
        automation.begin_properties.opacity = target_entity:get_opacity()
      end
    end
    if automation.end_properties.volume then
      if target_entity.get_volume then
        automation.begin_properties.volume = target:get_volume()
      end
    end
  end

  -- Updates properties on the target_entity.
  function automation:update_properties()
    for property_name, end_value in pairs(automation.end_properties) do
      local begin_value = automation.begin_properties[property_name]
      local delta = end_value - begin_value
      if delta ~= 0 then
        local new_value = automation.easing_func(automation.elapsed_time, begin_value, delta, automation.duration)
        new_value = math.floor(new_value)
        
        -- A bit dirty at the moment...
        if property_name == "x" then
          local current_x, current_y = target_entity:get_xy()
          target_entity:set_xy(new_value, current_y)
        elseif property_name == "y" then
          local current_x, current_y = target_entity:get_xy()
          target_entity:set_xy(current_x, new_value)
        elseif property_name == "opacity" then
          target_entity:set_opacity(new_value)
        elseif property_name == "volume" then
          target_entity:set_volume(new_value)
        end
      end
    end
  end

  -- Starts the automation.
  function automation:start()
    -- Stop the timer.
    if automation.timer ~= nil then
      automation.timer:stop()
    end

    -- Save the current values as the begin_properties
    if not automation.interrupted then
      automation:init_properties()
    end

    -- Reset the state.
    automation.stopped = false
    automation.finished = automation.elapsed_time >= automation.duration
    automation.interrupted = false

    -- Launch the automation if not already finished.
    if not automation.finished then
      -- Launch the timer.
      automation.timer = sol.timer.start(context, automation.update_delta, function()
        -- Update elapsed time since launch of automation.
        automation.elapsed_time = automation.elapsed_time + automation.update_delta

        -- Update properties of  the target_entity.
        automation:update_properties()
        
        -- Check if the automation is finished.
        if automation.elapsed_time < automation.duration then
          -- The automation is not done yet: keep on updating.
          return true
        else
          -- Update the state.
          automation.stopped = true
          automation.finished = true
          automation.interrupted = false
  
          -- The automation is done: call the callback.
          if automation.on_finished ~= nil then
            automation.on_finished()
          end
          
          -- Stop the timer.
          return false
        end
      end)
    end
  end

  -- Stops the automation.
  function automation:stop()
    -- Stop the timer.
    if automation.timer ~= nil then
      automation.timer:stop()
    end

    -- Reset the state.
    automation.stopped = true
    automation.finished = automation.elapsed_time >= automation.duration
    automation.interrupted = true
  end

  -- Return automation.
  return automation

end

-- Return table to the caller.
return automation_builder
