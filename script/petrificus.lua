-- Petrificus Totalus: permanent movement disable for the target.
--
-- - Player target -> moved into a permission group that blocks the
--   movement and manual-mining input actions but leaves the rest of the
--   game accessible (build, ghost placement via map, blueprints, crafting,
--   chat, GUIs). The character stays in the world but cannot walk and
--   cannot directly mine. The player still plays — from the radar, with
--   construction bots. Sticky across save / load.
-- - Unit target (biter / spitter) -> stop command issued at maximum
--   ticks_to_wait. Persists with the unit's saved state.
local Log = require("script.log")
local Petrificus = {}

local PETRIFY_RADIUS = 2.5
local PETRIFY_GROUP_NAME = "hmfea-petrified-player"

-- Input actions disabled for petrified players. Anything not on this list is
-- allowed (Factorio permission groups default to all-allowed for new groups).
-- The intent is "frozen on the spot, but ghost placement + blueprints +
-- construction bots still work". So we block movement, manual mining, and
-- hand-crafting. Ghost placement via the map and blueprint / deconstruction
-- tooling stay enabled — that's how the petrified player still plays.
local PETRIFIED_DENIED = {
    "start_walking",   -- WASD movement
    "begin_mining",    -- start manual entity mining
    "craft",           -- queue a craft in the player's character
}

local function init_storage()
    storage = storage or {}
    storage.petrificus = storage.petrificus or {}
    storage.petrificus.units = storage.petrificus.units or {}
    storage.petrificus.players = storage.petrificus.players or {}
end

function Petrificus.on_init()
    init_storage()
end

function Petrificus.on_configuration_changed()
    init_storage()
end

local function get_or_create_petrify_group()
    local group = game.permissions.get_group(PETRIFY_GROUP_NAME)
    if group then return group end
    group = game.permissions.create_group(PETRIFY_GROUP_NAME)
    -- New groups default to all-allowed; we only flip the denied actions.
    for _, action_name in ipairs(PETRIFIED_DENIED) do
        local id = defines.input_action[action_name]
        if id then
            group.set_allows_action(id, false)
        end
    end
    return group
end

local function petrify_unit(entity)
    if not (entity and entity.valid) then return end
    init_storage()
    storage.petrificus.units[entity.unit_number] = true
    entity.set_command({
        type = defines.command.stop,
        ticks_to_wait = 4294967295,
        distraction = defines.distraction.none,
    })
    Log.debug("petrificus", string.format(
        "event=petrified target=unit name=%s id=%d",
        entity.name, entity.unit_number
    ))
end

local function petrify_player(player)
    if not (player and player.valid) then return end
    init_storage()
    if storage.petrificus.players[player.index] then return end
    storage.petrificus.players[player.index] = true
    local group = get_or_create_petrify_group()
    group.add_player(player)
    player.print({ "hmfea.petrified-player" })
    Log.debug("petrificus", string.format(
        "event=petrified target=player player=%d",
        player.index
    ))
end

function Petrificus.on_script_trigger_effect(event)
    if event.effect_id ~= "hmfea-petrify" then return end
    local pos = event.target_position or event.source_position
    if not pos then return end
    local surface = game.get_surface(event.surface_index)
    if not surface then return end
    local area = {
        { pos.x - PETRIFY_RADIUS, pos.y - PETRIFY_RADIUS },
        { pos.x + PETRIFY_RADIUS, pos.y + PETRIFY_RADIUS },
    }
    for _, entity in pairs(surface.find_entities(area)) do
        if not entity.valid then
            -- skip
        elseif entity.type == "character" then
            for _, p in pairs(game.players) do
                if p.character == entity then
                    petrify_player(p)
                    break
                end
            end
        elseif entity.type == "unit" then
            petrify_unit(entity)
        end
    end
end

function Petrificus.on_tick(event)
    -- Reserved hardening hook. The unit stop command holds for unit lifetime
    -- via ticks_to_wait = uint32_max; the player petrify holds via the
    -- permission group. Re-issue logic intentionally deferred until we see
    -- a case where commands or group membership get overridden.
end

function Petrificus.on_player_joined_game(event)
    init_storage()
    if storage.petrificus.players[event.player_index] then
        local player = game.get_player(event.player_index)
        if player and player.valid then
            local group = get_or_create_petrify_group()
            group.add_player(player)
        end
    end
end

return Petrificus
