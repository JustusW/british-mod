-- EU Flag drops on biter / spitter death. Robot mining is blocked by the
-- "not-deconstructable" entity-prototype flag (see prototypes/eu-flag.lua) —
-- the deconstruction planner refuses to mark the flag, so no robot is ever
-- dispatched. Players who hand-mine a flag in under 30 seconds (i.e. with
-- mining-speed upgrades) trigger a respawn at the next tier (1.5× bigger /
-- slower), capped at tier 5.
local Log = require("script.log")
local EuFlag = {}

local FLAG_TIER_COUNT = 5
local FLAG_BASE_NAME = "hmfea-eu-flag"
local MIN_MINING_TICKS = 30 * 60  -- 30 seconds @ 60 ticks/s

local BITER_NAMES = {
    ["small-biter"] = true, ["medium-biter"] = true, ["big-biter"] = true, ["behemoth-biter"] = true,
    ["small-spitter"] = true, ["medium-spitter"] = true, ["big-spitter"] = true, ["behemoth-spitter"] = true,
}

local function flag_name_for_tier(tier)
    if tier <= 1 then return FLAG_BASE_NAME end
    return FLAG_BASE_NAME .. "-tier-" .. tier
end

-- Returns the tier number (1..N) for any flag prototype name; nil otherwise.
local function tier_of(name)
    if name == FLAG_BASE_NAME then return 1 end
    local match = string.match(name, "^" .. FLAG_BASE_NAME .. "%-tier%-(%d+)$")
    if match then return tonumber(match) end
    return nil
end

local function init_storage()
    storage = storage or {}
    storage.eu_flag = storage.eu_flag or {}
    storage.eu_flag.mining_starts = storage.eu_flag.mining_starts or {}
    storage.eu_flag.respawn_queue = storage.eu_flag.respawn_queue or {}
end

function EuFlag.on_init()
    init_storage()
end

function EuFlag.on_configuration_changed()
    init_storage()
end

function EuFlag.on_entity_died(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    if not BITER_NAMES[entity.name] then return end
    local surface = entity.surface
    if not surface then return end
    local pos = entity.position
    local flag = surface.create_entity({
        name = FLAG_BASE_NAME,
        position = pos,
        force = "neutral",
    })
    if flag then
        Log.debug("eu-flag", string.format(
            "event=spawned x=%.1f y=%.1f from=%s",
            pos.x, pos.y, entity.name
        ))
    end
end

-- Per-tick mining-state polling. Detects mining-start transitions per player.
function EuFlag.on_tick(event)
    if not storage.eu_flag then init_storage() end

    -- Process respawn queue first.
    if #storage.eu_flag.respawn_queue > 0 then
        local remaining = {}
        for _, entry in ipairs(storage.eu_flag.respawn_queue) do
            if event.tick >= entry.tick then
                local surface = game.get_surface(entry.surface_index)
                if surface then
                    local new_name = flag_name_for_tier(entry.tier)
                    surface.create_entity({
                        name = new_name,
                        position = entry.position,
                        force = "neutral",
                    })
                    Log.debug("eu-flag", string.format(
                        "event=respawned tier=%d x=%.1f y=%.1f",
                        entry.tier, entry.position.x, entry.position.y
                    ))
                end
            else
                table.insert(remaining, entry)
            end
        end
        storage.eu_flag.respawn_queue = remaining
    end

    -- Update mining-start records.
    local mining_starts = storage.eu_flag.mining_starts
    for _, player in pairs(game.connected_players) do
        local mining_state = player.mining_state
        local is_mining = mining_state and mining_state.mining
        local selected = player.selected
        local stored = mining_starts[player.index]

        if is_mining and selected and selected.valid and tier_of(selected.name) then
            if not stored or stored.unit_number ~= selected.unit_number then
                mining_starts[player.index] = {
                    unit_number = selected.unit_number,
                    start_tick = event.tick,
                }
            end
        else
            if stored then mining_starts[player.index] = nil end
        end
    end
end

function EuFlag.on_pre_player_mined_item(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    local current_tier = tier_of(entity.name)
    if not current_tier then return end
    if current_tier >= FLAG_TIER_COUNT then return end

    init_storage()
    local stored = storage.eu_flag.mining_starts[event.player_index]
    if not stored or stored.unit_number ~= entity.unit_number then return end

    local elapsed = game.tick - stored.start_tick
    if elapsed >= MIN_MINING_TICKS then return end

    -- Queue a respawn at the same spot, one tier higher, on the next tick.
    table.insert(storage.eu_flag.respawn_queue, {
        tick = game.tick + 1,
        position = { x = entity.position.x, y = entity.position.y },
        surface_index = entity.surface.index,
        tier = current_tier + 1,
    })
    Log.debug("eu-flag", string.format(
        "event=fast_mine tier_was=%d elapsed_ticks=%d player=%d",
        current_tier, elapsed, event.player_index
    ))

    -- Notify the player that their cleverness has been noted.
    local player = game.get_player(event.player_index)
    if player and player.valid then
        player.create_local_flying_text({
            text = { "hmfea.eu-flag-respawn" },
            position = entity.position,
        })
    end

    storage.eu_flag.mining_starts[event.player_index] = nil
end

return EuFlag
