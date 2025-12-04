local player = require("player")
local attacks = {
    rectanglehitzones = {},
    circlehitzones = {}
}
local elapsedtime = 0

function attacks.colortransition(startcolor1, startcolor2, startcolor3, endcolor1, endcolor2, endcolor3, transitiontime, flashtime)
    transitionstart = elapsedtime
    local colordiff1 = startcolor1 - endcolor1
    local colordiff2 = startcolor2 - endcolor2
    local colordiff3 = startcolor3 - endcolor3
    love.graphics.print(colordiff1 .. ", " .. colordiff2 .. ", " .. colordiff3, 0, 120)
    love.graphics.print(transitionstart, 0, 135)
    return colordiff1, colordiff2, colordiff3
end

function attacks.createrectanglehitzone(x, y, sizex, sizey, chargetime, linger)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, sizex, sizey)
    table.insert(attacks.rectanglehitzones, {x, y, sizex, sizey})
end

function attacks.createcirclehitzone(x, y, radius, chargetime, linger)
    love.graphics.setColor(0, 0, 1)
    love.graphics.circle("fill", x, y, radius)
    table.insert(attacks.circlehitzones, {x, y, radius})
end

function attacks.isinhitzone()
    -- Rectangle
    for _, tab in ipairs(attacks.rectanglehitzones) do
        if player.hitx < tab[1] + tab[3] and player.hitx + player.hitsize > tab[1] then
            if player.hity < tab[2] + tab[4] and player.hity + player.hitsize > tab[2] then
                return true
            end
        end
    end

    -- Circle
    for _, circle in ipairs(attacks.circlehitzones) do
        local circlex = circle[1]
        local circley = circle[2]
        local circleradius = circle[3]

        local nearestx = math.max(circleX - circleRadius, math.min(player.hitx + player.hitsize / 2, circlex + circleradius))
        local nearesty = math.max(circleY - circleRadius, math.min(player.hity + player.hitsize / 2, circley + circleradius))

        local deltax = nearestx - (player.hitx + player.hitsize / 2)
        local deltay = nearesty - (player.hity + player.hitsize / 2)

        if (deltax * deltax + deltay * deltay) < (circletadius * circletadius) then
            return true
        end
    end
    return false
end

function attacks.update(dt)
    elapsedtime = elapsedtime + dt
    if attacks.isinhitzone() then
        player.takedamage(0)
    end
end

function attacks.draw()
    attacks.createrectanglehitzone(100, 150, 100, 100)
    love.graphics.setColor(1, 1, 1)
    attacks.colortransition(1, 0, 1, 0, 1, 0, 5)
    if debug then
        love.graphics.print("Time: " .. elapsedtime, 0, 105)
    end
end

return attacks