local inputs = require("inputs")
local player = {
    x = 200, -- Info
    y = 200,
    hitx = 0,
    hity = 0,
    timer = 0,
    health = 5,
    shield = 5,
    size = 50,
    hitsize = 10,
    invincible = false,

    base = {
        movementspeed = 500,
        invincibilitytime = 0.5,
        damagetaken = 1,
        damage = 1,
        cooldownreduce = 1,
    },

    items = {},
    statuseffects = {},

    stats = {
        movementspeed = 500,
        invincibilitytime = 50,
        damagetaken = 1,
        damage = 1,
        cooldownreduce = 1,
    }
}

function player.takedamage(damage)
    if player.invincible == false and damage ~= nil then
        player.invincible = true
        player.timer = player.stats.invincibilitytime
        player.shield = player.shield - damage * player.stats.damagetaken
        if player.shield < 0 then
            player.health = player.health + player.shield
            player.shield = 0
        end
    end
end

-- Items
--{
--    name = "",
--    description = "",
--    effect = {},
--    bonus = ""
--}

function player.giveitem(name)
    table.insert(player.items, assets.items["jsontab"][name])
end

function player.giveitemdebug(name, description, effect, bonus)
    item = {name = name,
            description = description,
            effect = {movementspeed = effect.movementspeed, invincibilitytime = effect.invincibilitytime, damagetaken = effect.damagetaken},
            bonus = bonus,
            id = #player.items + 1}
    table.insert(player.items, item)
end

function player.calculatestats()
    local newstats = {}
    for key, value in pairs(player.base) do
        newstats[key] = value
    end
    for _, item in pairs(player.items) do -- Base, Upgrade, Item, Effect
        newstats.movementspeed = item.effect.movementspeed + newstats.movementspeed
        newstats.damagetaken = item.effect.damagetaken + newstats.damagetaken
        newstats.invincibilitytime = item.effect.invincibilitytime + newstats.invincibilitytime
        newstats.damage = item.effect.damagetaken + newstats.invincibilitytime
    end
    player.stats = newstats
end

--forgot to set up ui drawer before effect drawer. whoops
--local function playereffectdrawer()
--    effectcount = #player.statuseffects
--    for _, effect in player.statuseffects do
--
--    end
--end

--local function playeruidrawer()
--
--end

function player.update(dt)
    local w, h = love.graphics.getDimensions()
    local _, direction = inputs.get_current_inputs(main.input_mode)

    player.calculatestats()

    player.x = player.x + direction.x * dt * player.stats.movementspeed -- Movement
    player.y = player.y + direction.y * dt * player.stats.movementspeed

    if player.x < 0 then -- Border collision
        player.x = 0
    end
    if player.x > w - player.size then
        player.x = w - player.size
    end
    if player.y < 0 then
        player.y = 0
    end
    if player.y > h - player.size then
        player.y = h - player.size
    end

    player.hitx = player.x + (player.size - player.hitsize) / 2
    player.hity = player.y + (player.size - player.hitsize) / 2

    if player.timer < 0 then -- Invincibilitytime
        player.invincible = false
    else
    end
    if player.invincible then
        player.timer = player.timer - dt
    end
end

function player.draw()
    love.graphics.circle("fill", player.x + player.size / 2, player.y + player.size / 2, player.size / 2)

    if main.debug then
        if inputs.button_pressed("basic", main.input_mode) then
            love.graphics.setColor(0.5, 0.5, 0.5)
        elseif inputs.button_pressed("ability 1", main.input_mode) then
            love.graphics.setColor(1, 0, 0)
        elseif inputs.button_pressed("ability 2", main.input_mode) then
            love.graphics.setColor(0, 1, 0)
        elseif inputs.button_pressed("ability 3", main.input_mode) then
            love.graphics.setColor(0, 0, 1)
        elseif inputs.button_pressed("extra 1", main.input_mode) then
            love.graphics.setColor(1, 1, 0)
        elseif inputs.button_pressed("extra 2", main.input_mode) then
            love.graphics.setColor(1, 0, 1)
        elseif inputs.button_pressed("extra 3", main.input_mode) then
            love.graphics.setColor(0, 1, 1)
        elseif inputs.button_pressed("interact", main.input_mode) then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        love.graphics.setLineWidth(player.hitsize/3)
        love.graphics.circle("line", player.x + player.size / 2, player.y + player.size / 2, player.hitsize)
        love.graphics.setColor(0, 0, 1)

        love.graphics.print("Player X: " .. player.x .. ", " .. "Player Y: " .. player.y, 0, 60)
        love.graphics.print("Player Hit X: " .. player.hitx .. ", " .. "Player Hit Y: " .. player.hity, 0, 75)
        love.graphics.print("Player Size: " .. player.size .. ", " .. "Player Speed: " .. player.stats.movementspeed, 0, 90)
        love.graphics.print("Player Health: " .. player.health .. ", Player Shield: " .. player.shield .. ", Invincibility Time: " .. player.timer, 0, 105)
    end
end

return player