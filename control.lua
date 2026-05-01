-- Gated debug logger. All script-side debug output goes here, not to chat.
-- Gated on the runtime-global setting `hmfea-debug-logs` (see settings.lua).
-- Format: "[<subsystem>] tick=N key=value key=value ..."
local function debug_log(subsystem, line)
    if not settings.global["hmfea-debug-logs"].value then return end
    helpers.write_file(
        "hmfea-debug.txt",
        string.format("[%s] tick=%d %s\n", subsystem, game.tick, line),
        true
    )
end

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
    if event.item.name ~= "medkit" then return end
    local delay = math.random(1800, 7200)  -- 30-120 seconds at 60 ticks/s
    storage.healing_tick = delay
    debug_log("medkit", string.format(
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
                player.character.damage(-2000, player.force.name)
                count = count + 1
            end
        end
        debug_log("medkit", string.format(
            "event=heal_fired healed=%d amount=%d",
            count, 2000
        ))
        storage.healing_tick = -1  -- back to idle
    else
        storage.healing_tick = storage.healing_tick - 1
    end
end)
