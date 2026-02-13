local inputs = {joysticks = {}}
local pressedkeys = {}
local pressedbuttons = {}
local joysticks = love.joystick.getJoysticks()
inputs.joysticks = joysticks

for _, joystick in ipairs(love.joystick.getJoysticks()) do
    print("Connected: " .. joystick:getName())
end

function normalize(vector)
    local length = math.sqrt(vector.x ^ 2 + vector.y ^ 2)
    if length > 0.7 then
        return {x = vector.x / length, y = vector.y / length}
    else
        return vector
    end
end

function inputs.button_pressed (button, inputmode, id)
    for _, value in ipairs(inputs.get_current_inputs(inputmode, id)) do
        if value == button then
            return true
        end
    end
    return false
end

-- Keyboard Map
    local keyboard_movement_map = {
        ["w"] = {x = 0, y = -1}, -- Up
        ["s"] = {x = 0, y = 1}, -- Down
        ["a"] = {x = -1, y = 0}, -- Left
        ["d"] = {x = 1, y = 0}, -- Right
    }

    local keyboard_action_map = {
        ["space"] = "basic",
        ["1"] = "ability 1",
        ["2"] = "ability 2",
        ["3"] = "ability 3",
        ["q"] = "extra 1",
        ["e"] = "extra 2",
        ["r"] = "ult",
        ["f"] = "interact",
        -- Keyboard Specific
        ["f11"] = "fullscreen",
        ["f10"] = "debug",
        ["pageup"] = "up",
        ["pagedown"] = "down"
    }

    function love.keypressed(key)
        pressedkeys[key] = true
    end

    function love.keyreleased(key)
        pressedkeys[key] = nil
    end

    function keyboard_inputs()
        local currentdirection = {x = 0, y = 0}
        local currentactions = {}

        for key, direction in pairs(keyboard_movement_map) do
            if pressedkeys[key] then
                currentdirection.x = currentdirection.x + direction.x
                currentdirection.y = currentdirection.y + direction.y
            end
        end

        for key, action in pairs(keyboard_action_map) do
            if pressedkeys[key] then
                table.insert(currentactions, action)
            end
        end

        return currentactions, normalize(currentdirection)
    end

-- Controller Map
    local gamepad_action_map = {
        ["a"] = "basic",
        ["x"] = "ability 1",
        ["y"] = "ability 2",
        ["b"] = "ability 3",
        ["dpleft"] = "extra 1",
        ["dpup"] = "extra 2",
        ["dpright"] = "ult",
        ["dpdown"] = "interact",
    }

    function love.gamepadpressed(joystick, button)
        if not pressedbuttons[joystick] then
            pressedbuttons[joystick] = {}
        end
        pressedbuttons[joystick][button] = true
    end

    function love.gamepadreleased(joystick, button)
        if pressedbuttons[joystick] then
            pressedbuttons[joystick][button] = nil
        end
    end

    function gamepad_inputs(joystick)
        local currentactions = {}
        local currentdirection = {x = 0, y = 0}
        local deadzone = 0.15
        if joystick and joystick:isConnected() and joystick:isGamepad() then

            local x = joystick:getGamepadAxis("leftx")
            local y = joystick:getGamepadAxis("lefty")

            if math.abs(x) < deadzone then x = 0 end
            if math.abs(y) < deadzone then y = 0 end

            currentdirection.x = x
            currentdirection.y = y

            local buttonsforjoystick = pressedbuttons[joystick] or {}

            for button, action in pairs(gamepad_action_map) do
                if buttonsforjoystick[button] then
                    table.insert(currentactions, action)
                end
            end
        end

        return currentactions, normalize(currentdirection)
    end

function inputs.get_current_inputs(inputmode, id)
    inputlist = {}
    inputs.joysticks = joysticks

    if inputmode == "Keyboard" then
        return keyboard_inputs()
    elseif inputmode == "Controller" then
        return gamepad_inputs(joysticks[id])
    else
        print("Invalid input mode (" .. inputmode .. ")")
        return keyboard_inputs()
    end
end

return inputs