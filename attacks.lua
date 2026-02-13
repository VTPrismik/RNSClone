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
        attacks.createrectanglehitbox(0, 0, x, main.resolution.height, chargetime, 1)
    end
    if direction == "right" then
        attacks.createrectanglehitbox(x, 0, main.resolution.width - x, main.resolution.height, chargetime, 1)
    end
    if direction == "up" then
        attacks.createrectanglehitbox(0, 0, main.resolution.width, y, chargetime, 1)
    end
    if direction == "down" then
        attacks.createrectanglehitbox(0, y, main.resolution.width, main.resolution.height - y, chargetime, 1)
    end
end

function attacks.isinhitbox(p)
    -- Rectangle
    for _, tab in ipairs(attacks.rectanglehitboxes) do
        if p.hitx + p.hitsize > tab.x and p.hitx < tab.x + tab.sizex and p.hity + p.hitsize > tab.y and p.hity < tab.y + tab.sizey then
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
        local distance = math.sqrt((tab.x - p.hitx) ^ 2 + (tab.y - p.hity) ^ 2)
        if distance < tab.radius - p.hitsize / 2 then
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
    for _, p in ipairs(players) do
        if attacks.isinhitbox(p) then
            p.takedamage(1)
        end
    end
end

function attacks.draw()
    love.graphics.setColor(0, 1, 0)
        for i = #attacks.rectanglehitboxes, 1, -1 do
            local tab = attacks.rectanglehitboxes[i]

            if tab.chargetime < 0 then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", tab.x, tab.y, tab.sizex, tab.sizey)
                tab.linger = tab.linger - main.dt
                tab.active = true
            else
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle("fill", tab.x, tab.y, tab.sizex, tab.sizey)
                tab.chargetime = tab.chargetime - main.dt
                tab.active = false
            end

            if tab.linger < 0 then
                table.remove(attacks.rectanglehitboxes, i)
            end
        end

        for i = #attacks.circlehitboxes, 1, -1 do
            local tab = attacks.circlehitboxes[i]

            if tab.chargetime < 0 then
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("fill", tab.x, tab.y, tab.radius)
                tab.linger = tab.linger - main.dt
                tab.active = true
            else
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle("fill", tab.x, tab.y, tab.radius)
                tab.chargetime = tab.chargetime - main.dt
                tab.active = false
            end

            if tab.linger < 0 then
                table.remove(attacks.circlehitboxes, i)
            end
        end

    if main.debug then
        love.graphics.setColor(0, 1, 1)
    end
    love.graphics.setColor(1, 1, 1)
end

return attacks