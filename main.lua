local json = require("modules/json")

local inputs = require("inputs")
local player = require("player")
local attacks = require("attacks")

main = {
    elapsedtime = 0,
    winw = 0,
    winh = 0,
    playercount = 1,
    state = "Loading",
    debug = true,
    input_mode = "Controller",
    dt = 0
}

assets = {
    count = 0,
    effects = {},
    items = {}
}

local function loadasset(name, type)
    assets.count = assets.count + 1
    if type == "effects" then
        local image = "assets/" .. type .. "/" .. name .. ".png"
        imagedata = love.graphics.newImage(image)
        assets.effects[name] = {image = imagedata, id = assets.count}
    end
end

function reloadassets()
    assets = {
        count = 0,
        effects = {},
        items = {}
    }

    assets.items["file"] = io.open("assets/items.json")
    assets.items["jsonstr"] = assets.items["file"]:read("*all")
    assets.items["jsontab"] = json.decode(assets.items["jsonstr"])
    io.close(assets.items["file"])

    loadasset("judgement", "effect")
    loadasset("haunted", "effect")
    loadasset("shielded", "effect")
end

function love.load()
    main.winw, main.winh = love.graphics.getDimensions()

    reloadassets()

    player.giveitem("shield-generator")
    attacks.createshearhitbox(200, 200, "up", 1)
    attacks.createrectanglehitbox(300, 300, 100, 100, 1, 1000, true)

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

    if main.state == "Loading" then
        reloadassets()
        main.state = "Game"
    end
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