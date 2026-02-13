local json = require("modules/json")
local inputs = require("inputs")
local player = require("player")
local attacks = require("attacks")

time = love.timer.getTime()

deskwidth, deskheight = love.window.getDesktopDimensions()

main = {
    elapsedtime = 0,
    playercount = 1,
    state = "Loading",
    debug = true,
    dt = 0,
    scale = 1,
    baseresolution = {width = deskwidth, height = deskheight},
    resolution = {width = deskwidth, height = deskheight}
}

assets = {
    count = 0,
    effects = {},
    items = {}
}

players = {}

print()

local function loadimgasset(name, type)
    if type == "effects" then
        local image = "assets/" .. type .. "/" .. name .. ".png"
        imagedata = love.graphics.newImage(image)
        assets.effects[name] = {image = imagedata, id = assets.count}
    end
end

function reloadassets()
    assets = {
        effects = {},
        items = {},
    }

    assets.items["file"] = io.open("assets/items.json")
    assets.items["jsonstr"] = assets.items["file"]:read("*all")
    assets.items["jsontab"] = json.decode(assets.items["jsonstr"])
    io.close(assets.items["file"])

    loadimgasset("judgement", "effect")
    loadimgasset("haunted", "effect")
    loadimgasset("shielded", "effect")
end

function love.load()
    love.window.setMode(main.resolution.width, main.resolution.height)

    table.insert(players, player.newplayer(1, "Controller"))
    table.insert(players, player.newplayer(2, "Keyboard"))

    reloadassets()

    players[1].giveitem("speed_potion")
    players[1].giveitem("shield_potion")
    players[1].giveeffect("speed_boost", 20)
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
    print(time)
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

    if inputs.button_pressed("fullscreen", "Keyboard") and not fullscreenheld then
        fullscreenheld = true

        if not love.window.getFullscreen() then
            prevresolution = {width = main.resolution.width, height = main.resolution.height}
            prevscale = main.scale
            main.scale = 1
            main.resolution.width = main.baseresolution.width
            main.resolution.height = main.baseresolution.height
            love.window.setMode(main.resolution.width, main.resolution.height, {fullscreen = true})
        else
            main.scale = prevscale
            main.resolution.width = prevresolution.width
            main.resolution.height = prevresolution.height
            love.window.setMode(main.resolution.width, main.resolution.height, {fullscreen = false})
        end

    end

    if not inputs.button_pressed("fullscreen", "Keyboard") and fullscreenheld then
        fullscreenheld = false
    end

    if inputs.button_pressed("up", "Keyboard") and not upheld then
        upheld = true
        main.scale = main.scale + 0.25
        main.resolution.width = main.baseresolution.width * main.scale
        main.resolution.height = main.baseresolution.height * main.scale
        love.window.setMode(main.resolution.width, main.resolution.height)
    end
    if not inputs.button_pressed("up", "Keyboard") and upheld then
        upheld = false
    end

    if inputs.button_pressed("down", "Keyboard") and not downheld then
        downheld = true
        main.scale = main.scale - 0.25
        main.resolution.width = main.baseresolution.width * main.scale
        main.resolution.height = main.baseresolution.height * main.scale
        love.window.setMode(main.resolution.width, main.resolution.height)
    end
    if not inputs.button_pressed("down", "Keyboard") and downheld then
        downheld = false
    end

    --if player.health <= 0 then
    --    state = "Dead"
    --end

    if main.state == "Loading" then

    elseif main.state == "Game" then
        attacks.update(dt)
        for _, p in ipairs(players) do
            p.update()
        end

    elseif state == "Dead" then
    end
end

function love.draw()
    love.graphics.setColor(0, 0.2, 0)
    love.graphics.rectangle("fill", 0, 0, main.resolution.width, main.resolution.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.scale(main.scale)

    if main.state == "Loading" then
        reloadassets()
        main.state = "Game"
    end
    if main.state == "Main" then

    elseif main.state == "Game" then
        attacks.draw()
        for _, p in ipairs(players) do
            p.draw()
        end

    elseif main.state == "Dead" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end


    if main.debug then
        love.graphics.setColor(0, 1, 1)
        love.graphics.print("Width: " .. main.resolution.width .. ", " .. "Height: " .. main.resolution.height, 0, 15)
        love.graphics.print("Time: " .. main.elapsedtime, 0, 135)
        fps = love.timer.getFPS()
        love.graphics.print(fps, 0, 0)
    end
end