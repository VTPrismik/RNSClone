local inputs = require("inputs")

player = {}

function player.newplayer(id, inputmode)
    local player = {
        id = id, -- Info
        inputmode = inputmode,
        x = 200,
        y = 200,
        hitx = 0,
        hity = 0,
        timer = 0,
        maxhealth = 5,
        health = 0,
        shield = 5,
        size = 50,
        hitsize = 10,
        statcalccount = 0,
        usedshield = 0,
        usedheal = 0,
        class = "debug",
        invincible = false,

        items = {},
        statuseffects = {},

        base = {
            movementspeed = 500,
            speedpercent = 100,
            invincibilitytime = 0.5,
            damagetaken = 1,
            damage = 1,
            damagepercent = 100,
            cooldownreduce = 1,
            dodgechance = 0,
            meter = 0
        },
        stats = {
            movementspeed = 500,
            speedpercent = 100,
            invincibilitytime = 0.5,
            damagetaken = 1,
            damage = 1,
            damagepercent = 100,
            cooldownreduce = 1,
            dodgechance = 0,
            meter = 0
        }
    }

    player.health = player.maxhealth

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

    function player.giveitem(name)
        table.insert(player.items, assets.items["jsontab"][name])
        player.calculatestats()
    end

    function player.giveitemdebug(name, description, effect, bonus, calculatestats)
        calculatestats = calculatestats or false
        item = {
            name = name,
            description = description,
            effect = {movementspeed = effect.movementspeed, invincibilitytime = effect.invincibilitytime, damagetaken = effect.damagetaken},
            bonus = bonus,
            id = #player.items + 1
        }

        table.insert(player.items, item)
        if calculatestats then
            player.calculatestats()
        end
    end

    function player.giveeffect(name, length)
        effect = {type = name, length = length}
        table.insert(player.statuseffects, effect)
        player.calculatestats()
    end

    function player.calculatestats()
        local newstats = {}
        for key, value in pairs(player.base) do
            newstats[key] = value
        end
        for _, effect in ipairs(player.statuseffects) do
            newstats = player.effectupdate(effect, newstats)
        end
        for _, item in ipairs(player.items) do
            for effect in pairs(item.effect) do
                newstats[effect] = item.effect[effect] + newstats[effect]
            end
            if item.bonus.type ~= nil then
                player.bonusupdate(item.bonus.type, item.bonus.args)
            end
        end

        newstats.movementspeed = newstats.movementspeed * (newstats.speedpercent / 100)
        newstats.damage = newstats.damage * (newstats.damagepercent / 100)
        player.stats = newstats
    end

    function player.update()
        local _, direction = inputs.get_current_inputs(player.inputmode, player.id)

        for index = #player.statuseffects, 1, -1 do
            local effect = player.statuseffects[i]
            if effect ~= nil then
                effect.length = effect.length - main.dt
                if effect.length <= 0 then
                    table.remove(player.statuseffects, index)
                    player.calculatestats()
                end
            end
        end

        player.x = player.x + direction.x * main.dt * player.stats.movementspeed
        player.y = player.y + direction.y * main.dt * player.stats.movementspeed

        if player.x < 0 then
            player.x = 0
        end
        if player.x > main.resolution.width / main.scale - player.size then
            player.x = main.resolution.width / main.scale - player.size
        end
        if player.y < 0 then
            player.y = 0
        end
        if player.y > main.resolution.height / main.scale - player.size then
            player.y = main.resolution.height / main.scale - player.size
        end

        player.hitx = player.x + (player.size - player.hitsize) / 2
        player.hity = player.y + (player.size - player.hitsize) / 2

        if player.timer < 0 then
            player.invincible = false
            player.timer = 0
        else
        end
        if player.invincible then
            player.timer = player.timer - main.dt
        end
    end

    function player.draw()
        local actions, direction = inputs.get_current_inputs(player.inputmode, player.id)

        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", player.x + player.size / 2, player.y + player.size / 2, player.size / 2)

        if main.debug then
            if inputs.button_pressed("basic", player.inputmode, player.id) then
                love.graphics.setColor(0.5, 0.5, 0.5)
            elseif inputs.button_pressed("ability 1", player.inputmode, player.id) then
                love.graphics.setColor(1, 0, 0)
            elseif inputs.button_pressed("ability 2", player.inputmode, player.id) then
                love.graphics.setColor(0, 1, 0)
            elseif inputs.button_pressed("ability 3", player.inputmode, player.id) then
                love.graphics.setColor(0, 0, 1)
            elseif inputs.button_pressed("extra 1", player.inputmode, player.id) then
                love.graphics.setColor(1, 1, 0)
            elseif inputs.button_pressed("extra 2", player.inputmode, player.id) then
                love.graphics.setColor(1, 0, 1)
            elseif inputs.button_pressed("extra 3", player.inputmode, player.id) then
                love.graphics.setColor(0, 1, 1)
            elseif inputs.button_pressed("interact", player.inputmode, player.id) then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
            love.graphics.setLineWidth(player.hitsize/3)
            love.graphics.circle("line", player.x + player.size / 2, player.y + player.size / 2, player.hitsize)
            love.graphics.setColor(0, 1, 1)

            local actions_str = table.concat(actions, ", ")

            love.graphics.print("Actions: " .. actions_str, (id - 1) * 500, 45)
            love.graphics.print("Direction: (" .. direction.x .. ", " .. direction.y .. ")", (id - 1) * 500, 30)
            love.graphics.print("Player X: " .. player.x .. ", " .. "Player Y: " .. player.y, (id - 1) * 500, 60)
            love.graphics.print("Player Hit X: " .. player.hitx .. ", " .. "Player Hit Y: " .. player.hity, (id - 1) * 500, 75)
            love.graphics.print("Player Size: " .. player.size .. ", " .. "Player Speed: " .. player.stats.movementspeed, (id - 1) * 500, 90)
            love.graphics.print("Player Health: " .. player.health .. ", Player Shield: " .. player.shield .. ", Invincibility Time: " .. player.timer, (id - 1) * 500, 105)
        end
    end

    function player.effectupdate(effect, newstats)
        if effect.type == "slowness" then
            newstats.movementspeed = newstats.movementspeed * 0.8

        elseif effect.type == "speed_boost" then
            newstats.movementspeed = newstats.movementspeed * 1.2

        elseif effect.type == "damage_boost" then
            newstats.damagepercent = newstats.damagepercent * 1.2

        elseif effect.type == "invulnerability_boost" then
            newstats.invincibilitytime = newstats.invincibilitytime * 1.2

        elseif effect.type == "cooldown_boost" then
            newstats.cooldownreduce = newstats.cooldownreduce * 1.2

        elseif effect.type == "dodge_boost" then
            newstats.dodgechance = newstats.dodgechance * 1.2

        end
        effect.length = effect.length - main.dt
        return newstats
    end

    function player.bonusupdate(type, args)
        if type == "shield" then
            local newshield = 0
            for _, item in ipairs(player.items) do
                if item.bonus.type == "shield" then
                    newshield = newshield + 1
                end
            end
            newshield = math.max(0, newshield - player.usedshield)
            player.shield = player.shield + args["1"] * newshield
            player.usedshield = player.usedshield + newshield
        end
        if type == "heal" then
            local newheal = 0
            for _, item in ipairs(player.items) do
                if item.bonus.type == "heal" then
                    newheal = newheal + 1
                end
            end
            newheal = math.max(0, newheal - player.usedheal)
            player.health = math.max(player.maxhealth, player.health + args["1"] * newheal)
            player.usedheal = player.usedheal + newheal
        end
    end
    return player
end

return player