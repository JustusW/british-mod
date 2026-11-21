-- Spidertron: "Get that thing outta here!" On build, a screaming voice clip
-- plays at the spidertron, and SCREAM_TICKS later it explodes (entity.die(),
-- so the vanilla spidertron-explosion and remnants appear).
local Log = require("script.log")
local Spidertron = {}

local SPIDER_TYPE = "spider-vehicle"
local SOUND_PATH = "hmfea-get-that-thing-outta-here"
local SCREAM_TICKS = 120  -- about the clip length; retune when the clip lands

local function init_storage()
    storage = storage or {}
    storage.spidertron = storage.spidertron or {}
    storage.spidertron.doomed = storage.spidertron.doomed or {}
end

function Spidertron.on_init()
    init_storage()
end

function Spidertron.on_configuration_changed()
    init_storage()
end

function Spidertron.on_built(event)
    local e = event.entity
    if not (e and e.valid and e.type == SPIDER_TYPE) then return end
    init_storage()
    -- Silent until the clip exists (placeholder audio rule: voice lines are silent).
    if helpers.is_valid_sound_path(SOUND_PATH) then
        e.surface.play_sound({ path = SOUND_PATH, position = e.position })
    end
    storage.spidertron.doomed[e.unit_number] = { entity = e, at_tick = game.tick + SCREAM_TICKS }
    Log.debug("spidertron", string.format("event=doomed id=%d", e.unit_number))
end

function Spidertron.on_tick(event)
    local doomed = storage.spidertron and storage.spidertron.doomed
    if not (doomed and next(doomed)) then return end
    for id, entry in pairs(doomed) do
        if event.tick >= entry.at_tick then
            doomed[id] = nil
            if entry.entity.valid then
                entry.entity.die()
                Log.debug("spidertron", string.format("event=exploded id=%d", id))
            end
        end
    end
end

return Spidertron
