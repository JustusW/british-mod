-- Food cravings (On-Tick debuff). Per-player state machine:
--   Satiated  - duration 5 minutes base + random 0-5 minutes on top
--   Craving   - duration 1 minute
--   Craven    - infinite, until food is eaten
-- Eating Cuppa Tea or Fish & Chips resets the cycle to Satiated.
-- While any player on a force is in Craven, every assembling-machine /
-- furnace / lab / rocket-silo / mining-drill on that force is set inactive
-- (factory shutdown). Restored when no Craven player remains on the force.
-- Reaching Craven also fires the Bloody Uncivilised achievement.
local Log = require("script.log")
local Cravings = {}

local STAGE_SATIATED = "satiated"
local STAGE_CRAVING = "craving"
local STAGE_CRAVEN = "craven"

local CRAVING_TICKS = 60 * 60               -- 1 minute @ 60 ticks/s
local SATIATED_BASE_TICKS = 60 * 60 * 5     -- 5 minutes minimum
local SATIATED_RANDOM_RANGE_TICKS = 60 * 60 * 5  -- + random 0-5 minutes on top
local CHECK_INTERVAL = 60                   -- check stage transitions once per second

local SHUTDOWN_TYPES = {
    "assembling-machine",
    "furnace",
    "lab",
    "rocket-silo",
    "mining-drill",
}

local FOOD_ITEMS = {
    ["hmfea-cuppa-tea"] = true,
    ["hmfea-fish-and-chips"] = true,
}

local function init_storage()
    storage = storage or {}
    storage.cravings = storage.cravings or {}
    storage.cravings.players = storage.cravings.players or {}
    storage.cravings.force_shutdowns = storage.cravings.force_shutdowns or {}
end

local function satiated_duration_ticks()
    return SATIATED_BASE_TICKS + math.random(0, SATIATED_RANDOM_RANGE_TICKS)
end

local function force_has_craven_player(force)
    for _, p in pairs(force.players) do
        local entry = storage.cravings.players[p.index]
        if entry and entry.stage == STAGE_CRAVEN then
            return true
        end
    end
    return false
end

local function shutdown_force(force)
    if storage.cravings.force_shutdowns[force.index] then return end
    local affected = {}
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered({
            force = force,
            type = SHUTDOWN_TYPES,
        })) do
            if entity.active then
                entity.active = false
                table.insert(affected, entity)
            end
        end
    end
    storage.cravings.force_shutdowns[force.index] = affected
    Log.debug("craving", string.format(
        "event=force_shutdown force=%d entities=%d",
        force.index, #affected
    ))
end

local function restore_force(force)
    local affected = storage.cravings.force_shutdowns[force.index]
    if not affected then return end
    local restored = 0
    for _, entity in pairs(affected) do
        if entity.valid then
            entity.active = true
            restored = restored + 1
        end
    end
    storage.cravings.force_shutdowns[force.index] = nil
    Log.debug("craving", string.format(
        "event=force_restored force=%d entities=%d",
        force.index, restored
    ))
end

local function update_force_shutdown(force)
    if force_has_craven_player(force) then
        shutdown_force(force)
    else
        restore_force(force)
    end
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
        entry.stage_ends_at = nil
    end

    if prev_stage and prev_stage ~= stage then
        Log.debug("craving", string.format(
            "event=stage_change player=%d from=%s to=%s",
            player_index, prev_stage, stage
        ))
    end

    if stage == STAGE_CRAVEN then
        local player = game.get_player(player_index)
        if player and player.valid then
            update_force_shutdown(player.force)
            player.unlock_achievement("hmfea-bloody-uncivilised")
            Log.debug("craving", string.format(
                "event=achievement_fired name=hmfea-bloody-uncivilised player=%d",
                player_index
            ))
        end
    elseif prev_stage == STAGE_CRAVEN then
        local player = game.get_player(player_index)
        if player and player.valid then
            update_force_shutdown(player.force)
        end
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
