-- Food cravings (On-Tick debuff). Per-player state machine:
--   Satiated  - duration 3600 * randint(5, 10) ticks
--   Craving   - duration 3600 ticks
--   Craven    - infinite, until food is eaten
-- Eating Cuppa Tea or Fish & Chips resets the cycle to Satiated.
-- Reaching Craven spawns a hmfea-craven-drain at the player's position to
-- impose a near-infinite electricity demand on the local power network and
-- (TODO) fires the Bloody Uncivilised achievement.
local Log = require("script.log")
local Cravings = {}

local STAGE_SATIATED = "satiated"
local STAGE_CRAVING = "craving"
local STAGE_CRAVEN = "craven"

local CRAVING_TICKS = 60 * 60               -- 1 minute @ 60 ticks/s
local SATIATED_MIN_MULTIPLIER = 5
local SATIATED_MAX_MULTIPLIER = 10
local CHECK_INTERVAL = 60                   -- check stage transitions once per second

local FOOD_ITEMS = {
    ["hmfea-cuppa-tea"] = true,
    ["hmfea-fish-and-chips"] = true,
}

local function init_storage()
    storage = storage or {}
    storage.cravings = storage.cravings or {}
    storage.cravings.players = storage.cravings.players or {}
end

local function satiated_duration_ticks()
    return CRAVING_TICKS * math.random(SATIATED_MIN_MULTIPLIER, SATIATED_MAX_MULTIPLIER)
end

local function ensure_drain(player_index)
    local player = game.get_player(player_index)
    if not (player and player.valid and player.character) then return end
    local entry = storage.cravings.players[player_index]
    if entry.drain and entry.drain.valid then return end
    local drain = player.surface.create_entity({
        name = "hmfea-craven-drain",
        position = player.position,
        force = player.force,
    })
    if drain then
        entry.drain = drain
    end
end

local function remove_drain(player_index)
    local entry = storage.cravings.players[player_index]
    if not entry then return end
    if entry.drain and entry.drain.valid then
        entry.drain.destroy()
    end
    entry.drain = nil
end

local function set_stage(player_index, stage, current_tick)
    local entry = storage.cravings.players[player_index]
    if not entry then
        entry = {}
        storage.cravings.players[player_index] = entry
    end
    local prev_stage = entry.stage
    entry.stage = stage
    if stage == STAGE_SATIATED then
        entry.stage_ends_at = current_tick + satiated_duration_ticks()
    elseif stage == STAGE_CRAVING then
        entry.stage_ends_at = current_tick + CRAVING_TICKS
    else
        entry.stage_ends_at = nil  -- infinite
    end

    if prev_stage and prev_stage ~= stage then
        Log.debug("craving", string.format(
            "event=stage_change player=%d from=%s to=%s",
            player_index, prev_stage, stage
        ))
    end

    if stage == STAGE_CRAVEN then
        ensure_drain(player_index)
        local player = game.get_player(player_index)
        if player and player.valid then
            player.unlock_achievement("hmfea-bloody-uncivilised")
            Log.debug("craving", string.format(
                "event=achievement_fired name=hmfea-bloody-uncivilised player=%d",
                player_index
            ))
        end
    elseif prev_stage == STAGE_CRAVEN then
        remove_drain(player_index)
    end
end

function Cravings.on_init()
    init_storage()
end

function Cravings.on_configuration_changed()
    init_storage()
end

function Cravings.on_player_joined_game(event)
    init_storage()
    local entry = storage.cravings.players[event.player_index]
    if not entry then
        set_stage(event.player_index, STAGE_SATIATED, game.tick)
    end
end

function Cravings.on_tick(event)
    if not storage.cravings then init_storage() end
    if event.tick % CHECK_INTERVAL ~= 0 then return end

    for _, player in pairs(game.connected_players) do
        local entry = storage.cravings.players[player.index]
        if not entry then
            set_stage(player.index, STAGE_SATIATED, event.tick)
        elseif entry.stage_ends_at and event.tick >= entry.stage_ends_at then
            if entry.stage == STAGE_SATIATED then
                set_stage(player.index, STAGE_CRAVING, event.tick)
                player.print({ "hmfea.craving-start" })
            elseif entry.stage == STAGE_CRAVING then
                set_stage(player.index, STAGE_CRAVEN, event.tick)
                player.print({ "hmfea.craven-start" })
            end
        end
    end
end

function Cravings.on_player_used_capsule(event)
    if not (event.item and FOOD_ITEMS[event.item.name]) then return end
    local player = game.get_player(event.player_index)
    set_stage(event.player_index, STAGE_SATIATED, game.tick)
    if player and player.valid then
        player.print({ "hmfea.cravings-reset" })
    end
end

return Cravings
