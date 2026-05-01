-- Tank protocol: while occupying the tank, "God Save the King" plays
-- continuously. Only mutable via global game audio settings.
-- Audio asset is TBD; placeholder uses a vanilla sound while in tank.
local Log = require("script.log")
local Tank = {}

local TANK_NAME = "tank"
local LOOP_INTERVAL = 60 * 5  -- play the placeholder sound every 5 seconds while in tank

local function init_storage()
    storage = storage or {}
    storage.tank = storage.tank or {}
    storage.tank.last_loop_tick = storage.tank.last_loop_tick or {}
end

function Tank.on_init()
    init_storage()
end

function Tank.on_configuration_changed()
    init_storage()
end

function Tank.on_player_driving_changed_state(event)
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    local vehicle = player.vehicle
    if vehicle and vehicle.valid and vehicle.name == TANK_NAME then
        Log.debug("tank", string.format("event=mounted player=%d", player.index))
        -- Kick the loop immediately
        if storage.tank then
            storage.tank.last_loop_tick[player.index] = -math.huge
        end
    else
        if storage.tank then
            storage.tank.last_loop_tick[player.index] = nil
        end
        Log.debug("tank", string.format("event=dismounted player=%d", player.index))
    end
end

function Tank.on_tick(event)
    if not storage.tank then init_storage() end
    if event.tick % LOOP_INTERVAL ~= 0 then return end
    for _, player in pairs(game.connected_players) do
        local vehicle = player.vehicle
        if vehicle and vehicle.valid and vehicle.name == TANK_NAME then
            -- Placeholder sound — once the audio asset lands, swap in the
            -- "God Save the King" loop here.
            player.play_sound({ path = "utility/new_objective" })
            storage.tank.last_loop_tick[player.index] = event.tick
        end
    end
end

return Tank
