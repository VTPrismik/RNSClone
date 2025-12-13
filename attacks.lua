local player = require("player")
local attacks = {
    rectanglehitboxes = {},
    circlehitboxes = {}
}

function attacks.createrectanglehitbox(x, y, sizex, sizey, chargetime, linger, invert)
    table.insert(attacks.rectanglehitboxes, {x = x, y = y, sizex = sizex, sizey = sizey, chargetime = chargetime, linger = linger, inverted = invert, active = false})
end

function attacks.createcirclehitbox(x, y, radius, chargetime, linger, invert)
    table.insert(attacks.circlehitboxes, {x = x, y = y, radius = radius, chargetime = chargetime, linger = linger, inverted = invert, active = false})
end

function attacks.createshearhitbox(x, y, direction, chargetime)
    if direction == "left" then
        attacks.createrectanglehitbox(0, 0, x, main.winh, chargetime, 1)
    end
    if direction == "right" then
        attacks.createrectanglehitbox(x, 0, main.winw - x, main.winh, chargetime, 1)
    end
    if direction == "up" then
        attacks.createrectanglehitbox(0, 0, main.winw, y, chargetime, 1)
    end
    if direction == "down" then
        attacks.createrectanglehitbox(0, y, main.winw, main.winh - y, chargetime, 1)
    end
end

function attacks.isinhitbox()
    -- Rectangle
    for _, tab in ipairs(attacks.rectanglehitboxes) do
        if player.hitx + player.hitsize > tab.x and player.hitx < tab.x + tab.sizex and player.hity + player.hitsize > tab.y and player.hity < tab.y + tab.sizey then
            if tab.active then
                if tab.invert then
                    return false
                else
                    return true
                end
            end
        end
    end
    -- Circle
    for _, tab in ipairs(attacks.circlehitboxes) do
        local distance = math.sqrt((tab.x - player.hitx) ^ 2 + (tab.y - player.hity) ^ 2)
        if distance < tab.radius - player.hitsize / 2 then
            if tab.active then
                if tab.invert then
                    return false
                else
                    return true
                end
            end
        end
    end
end

function attacks.update()
    if attacks.isinhitbox() then
        player.takedamage(1)
    end
end

function attacks.draw()
    love.graphics.setColor(0, 1, 0)
    -- Hitboxes
        for key, tab in ipairs(attacks.rectanglehitboxes) do
            if tab.chargetime < 0 then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", tab.x, tab.y, tab.sizex, tab.sizey)
                tab.linger = tab.linger - main.dt
                tab.active = false
                print("AAAAA")
                print(tab.x)
                print(tab.y)
                print(tab.sizex)
                print(tab.sizey)
            else
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle("fill", tab.x, tab.y, tab.sizex, tab.sizey)
                tab.chargetime = tab.chargetime - main.dt
                tab.active = false
            end
            if tab.linger < 0 then
                table.remove(attacks.rectanglehitboxes, key)
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", tab.x, tab.y, tab.sizex, tab.sizey)
            end
        end
        for key, tab in ipairs(attacks.circlehitboxes) do
            if tab.chargetime < 0 then
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("fill", tab.x, tab.y, tab.radius)
                tab.linger = tab.linger - main.dt
                tab.active = false
            else
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle("fill", tab.x, tab.y, tab.radius)
                tab.chargetime = tab.chargetime - main.dt
                tab.active = false
            end
            if tab.linger < 0 then
                table.remove(attacks.rectanglehitboxes, key)
            end
        end

    if main.debug then
        love.graphics.setColor(0, 0, 1)
        love.graphics.print("Time: " .. main.elapsedtime, 0, 120)
    end
    love.graphics.setColor(1, 1, 1)
end

return attacks