-- High-speed rail (requirements "High-speed rail"):
--   * a force keeps at most two normal locomotives; any further one explodes
--   * the HS3 train explodes on placement; the first one per force unlocks the
--     Steam Locomotive
--   * the first Steam Locomotive per force gets a voice line
--   * train stops named "Euston" refuse trains for their first 4 minutes
--   * every 20 minutes the northernmost planned rails far north are cancelled
local Log = require("script.log")
local Voice = require("script.voice")
local HsTrains = {}

local MAX_LOCOMOTIVES = 2
local DOOM_TICKS = 60
local EUSTON_TICKS = 4 * 60 * 60
local NORTH_TICKS = 20 * 60 * 60
local NORTH_DISTANCE = 200
local NORTH_COUNT = 20
local RAIL_TYPES = { "straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail",
    "legacy-straight-rail", "legacy-curved-rail" }

local function init_storage()
    storage.hs = storage.hs or {}
    storage.hs.doomed = storage.hs.doomed or {}
    storage.hs.steam_unlocked = storage.hs.steam_unlocked or {}
    storage.hs.steam_built = storage.hs.steam_built or {}
    storage.hs.euston = storage.hs.euston or {}
end

function HsTrains.on_init() init_storage() end
function HsTrains.on_configuration_changed() init_storage() end

local function say_force(force, key, text)
    for _, player in pairs(force.connected_players) do
        if text then player.print(text) end
        Voice.say(player, key)
    end
end

local function flying(force, entity, text)
    for _, player in pairs(force.connected_players) do
        player.create_local_flying_text({ text = text, position = entity.position, color = { r = 1, g = 0.4, b = 0.3 } })
    end
end

local function doom(entity)
    storage.hs.doomed[entity.unit_number] = { entity = entity, at_tick = game.tick + DOOM_TICKS }
end

local function locomotive_count(force)
    local n = 0
    for _, surface in pairs(game.surfaces) do
        n = n + surface.count_entities_filtered({ name = "locomotive", force = force })
    end
    return n
end

local function euston_check(stop)
    if not (stop and stop.valid and stop.type == "train-stop") then return end
    if not string.find(string.lower(stop.backer_name or ""), "euston", 1, true) then return end
    local id = stop.unit_number
    if storage.hs.euston[id] then return end
    storage.hs.euston[id] = { stop = stop, limit = stop.trains_limit, until_tick = game.tick + EUSTON_TICKS }
    stop.trains_limit = 0
    flying(stop.force, stop, { "hmfea.euston-closed" })
end

function HsTrains.on_built(event)
    local e = event.entity
    if not (e and e.valid) then return end
    if not storage.hs then init_storage() end
    local force = e.force
    if e.name == "locomotive" then
        if locomotive_count(force) > MAX_LOCOMOTIVES then
            doom(e)
            flying(force, e, { "hmfea.hs2-limit" })
            Log.debug("hs-trains", string.format("event=third_locomotive id=%d", e.unit_number))
        end
    elseif e.name == "hmfea-hs3-train" then
        doom(e)
        if not storage.hs.steam_unlocked[force.index] then
            storage.hs.steam_unlocked[force.index] = true
            force.recipes["hmfea-steam-locomotive"].enabled = true
            say_force(force, "hs3-explodes", { "hmfea.hs3-exploded" })
        end
        Log.debug("hs-trains", string.format("event=hs3_train id=%d", e.unit_number))
    elseif e.name == "hmfea-steam-locomotive" then
        if not storage.hs.steam_built[force.index] then
            storage.hs.steam_built[force.index] = true
            say_force(force, "steam-first", { "hmfea.steam-first" })
        end
    elseif e.type == "train-stop" then
        euston_check(e)
    end
end

function HsTrains.on_entity_renamed(event)
    if not storage.hs then init_storage() end
    euston_check(event.entity)
end

function HsTrains.on_research_started(event)
    local tech = event.research
    if tech and tech.valid and tech.name == "hmfea-hs2" then
        for _, player in pairs(tech.force.connected_players) do
            player.print({ "hmfea.research-hs2-started" })
            Voice.say(player, "research-hs2-started")
        end
    end
end

local function cancel_northern_leg()
    for _, surface in pairs(game.surfaces) do
        for _, force in pairs(game.forces) do
            if force.name ~= "enemy" and force.name ~= "neutral" then
                local spawn = force.get_spawn_position(surface)
                local ghosts = surface.find_entities_filtered({ type = "entity-ghost", ghost_type = RAIL_TYPES, force = force })
                local north = {}
                for _, g in pairs(ghosts) do
                    if g.position.y < spawn.y - NORTH_DISTANCE then table.insert(north, g) end
                end
                if #north > 0 then
                    table.sort(north, function(a, b) return a.position.y < b.position.y end)
                    for i = 1, math.min(NORTH_COUNT, #north) do north[i].destroy() end
                    say_force(force, "northern-leg", { "hmfea.northern-leg" })
                    Log.debug("hs-trains", string.format("event=northern_leg force=%d cancelled=%d", force.index, math.min(NORTH_COUNT, #north)))
                end
            end
        end
    end
end

function HsTrains.on_tick(event)
    if not storage.hs then init_storage() end
    local doomed = storage.hs.doomed
    for id, entry in pairs(doomed) do
        if event.tick >= entry.at_tick then
            doomed[id] = nil
            if entry.entity.valid then entry.entity.die() end
        end
    end
    if event.tick % 60 == 0 then
        for id, entry in pairs(storage.hs.euston) do
            if not entry.stop.valid then
                storage.hs.euston[id] = nil
            elseif event.tick >= entry.until_tick and not entry.reopened then
                entry.reopened = true
                entry.stop.trains_limit = entry.limit
            end
        end
    end
    if event.tick > 0 and event.tick % NORTH_TICKS == 0 then cancel_northern_leg() end
end

return HsTrains
