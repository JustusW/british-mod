-- Tank protocol: while occupying the tank, "God Save the King" plays
-- continuously. Only mutable via global game audio settings.
-- The clip (hmfea-god-save-the-king, ASSETS A1) is a 37.0 s loop and is
-- restarted every LOOP_TICKS while the player stays in the tank. A playing
-- sound can't be stopped, so leaving the tank lets the current verse finish.
-- Without the clip, a vanilla placeholder beep plays every 5 seconds.
local Log = require("script.log")
local Tank = {}

local TANK_NAME = "tank"
local CLIP = "hmfea-god-save-the-king"
local LOOP_TICKS = 2220            -- 37.0 s, the clip length
local PLACEHOLDER = "utility/new_objective"
local PLACEHOLDER_TICKS = 60 * 5
local CHECK_INTERVAL = 10

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
    if not storage.tank then init_storage() end
    local vehicle = player.vehicle
    -- Either way the next check starts fresh: on mount it plays at once.
    storage.tank.last_loop_tick[player.index] = nil
    if vehicle and vehicle.valid and vehicle.name == TANK_NAME then
        Log.debug("tank", string.format("event=mounted player=%d", player.index))
    else
        Log.debug("tank", string.format("event=dismounted player=%d", player.index))
    end
end

function Tank.on_tick(event)
    if event.tick % CHECK_INTERVAL ~= 0 then return end
    if not storage.tank then init_storage() end
    local has_clip = helpers.is_valid_sound_path(CLIP)
    local path = has_clip and CLIP or PLACEHOLDER
    local interval = has_clip and LOOP_TICKS or PLACEHOLDER_TICKS
    local last = storage.tank.last_loop_tick
    for _, player in pairs(game.connected_players) do
        local vehicle = player.vehicle
        if vehicle and vehicle.valid and vehicle.name == TANK_NAME then
            if not last[player.index] or event.tick - last[player.index] >= interval then
                player.play_sound({ path = path })
                last[player.index] = event.tick
            end
        end
    end
end

return Tank
