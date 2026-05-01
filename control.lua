local Log = require("script.log")

-- Heal magnitude: vanilla character max HP is 250; -2000 is an arbitrary
-- "large negative" that caps to full health on any reasonable build. Treat
-- as a sentinel for "full heal", not a literal HP figure.
local HEAL_AMOUNT = 2000

local function prepare_storage()
    storage = storage or {}
    if storage.healing_tick == nil then
        storage.healing_tick = -1  -- sentinel: no heal pending
    end
end

script.on_init(function()
    prepare_storage()
end)

script.on_configuration_changed(function()
    prepare_storage()
end)

script.on_event(defines.events.on_player_used_capsule, function(event)
    if event.item.name ~= "hmfea-medkit" then return end
    local delay = math.random(1800, 7200)  -- 30-120 seconds at 60 ticks/s
    storage.healing_tick = delay
    Log.debug("medkit", string.format(
        "event=used player=%d delay_ticks=%d",
        event.player_index, delay
    ))
end)

script.on_event(defines.events.on_tick, function(event)
    -- Idle: sentinel < 0, do nothing.
    if storage.healing_tick < 0 then return end

    if storage.healing_tick == 0 then
        local count = 0
        for _, player in pairs(game.players) do
            if player.character then
                player.character.damage(-HEAL_AMOUNT, player.force.name)
                count = count + 1
            end
        end
        Log.debug("medkit", string.format(
            "event=heal_fired healed=%d amount=%d",
            count, HEAL_AMOUNT
        ))
        storage.healing_tick = -1  -- back to idle
    else
        storage.healing_tick = storage.healing_tick - 1
    end
end)
