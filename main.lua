local inputs = require("inputs")
local player = require("player")
local attacks = require("attacks")

main = {
    elapsedtime = 0,
    winw = 0,
    winh = 0,
    playercount = 1,
    state = "Game",
    debug = true,
    input_mode = "Controller",
    dt = 0
}

assets = {
    count = 0,
    effect = {},
}

local function loadasset(name, type)
    assets.count = assets.count + 1
    if type == "effect" then
        local image = "assets/" .. type .. "/" .. name .. ".png"
        imagedata = love.graphics.newImage(image)
        table.insert(assets.effect, {name = name, image = imagedata, id = assets.count})
    end
end

function main.reloadassets()
    assets = {
        count = 0,
        effect = {},
    }

    -- Effects
    loadasset("judgement", "effect")
end

function love.load()
    main.winw, main.winh = love.graphics.getDimensions()

    player.giveitemdebug("TestName", "Test Description", {movementspeed = 200, invincibilitytime = 0.5, damagetaken = 1})
    attacks.createshearhitbox(200, 200, "up", 1)

    for _ , assettype in pairs(assets) do
        if type(assettype) == "table" then
            for _, asset in ipairs(assettype) do
                if main.debug then
                    print("Loaded: " .. asset.name .. " (" .. asset.id .. ")")
                end
            end
        end
    end
end

function love.update(dt)
    main.elapsedtime = main.elapsedtime + dt
    main.dt = dt
    if inputs.button_pressed("debug", "Keyboard") and not debugheld then
        debugheld = true
        main.debug = not main.debug
    end
    if not inputs.button_pressed("debug", "Keyboard") and debugheld then
        debugheld = false
    end
    --if player.health <= 0 then
    --    state = "Dead"
    --end

    if main.state == "AssetLoading" then
        --love.graphics.newImage("assets/effects/")
    elseif main.state == "Game" then
        attacks.update(dt)
        player.update(dt)
    elseif state == "Dead" then
    end
end

function love.draw()
    main.winw, main.winh = love.graphics.getDimensions()
    local actions, direction = inputs.get_current_inputs(input_mode)
    local actions_str = table.concat(actions, ", ")

    love.graphics.setColor(0, 0.5, 0)
    love.graphics.rectangle("fill", 0, 0, main.winw, main.winh)
    love.graphics.setColor(1, 1, 1)

    if main.state == "Main" then

    elseif main.state == "Game" then
        attacks.draw()
        player.draw()

    elseif main.state == "Dead" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end

    if main.debug then
        love.graphics.setColor(0, 0, 1)
        love.graphics.print("Width: " .. main.winw .. ", " .. "Height: " .. main.winh, 0, 15)
        love.graphics.print("Actions: " .. actions_str, 0, 45)
        love.graphics.print("Direction: (" .. direction.x .. ", " .. direction.y .. ")", 0, 30)
        fps = love.timer.getFPS()
        love.graphics.print(fps, 0, 0)
    end
end