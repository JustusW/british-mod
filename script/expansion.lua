-- Expansion party AI bias. Per requirements: biter expansion parties prefer
-- to settle near oil patches; resource patches are a fallback. Regular
-- attack groups are unaffected.
--
-- We hook on_unit_group_finished_gathering and only retarget groups whose
-- command type is build_base. The new destination is the nearest crude-oil
-- entity, or the nearest resource entity if no oil is reachable.
local Log = require("script.log")
local Expansion = {}

local SEARCH_RADIUS = 256
local PRIMARY_RESOURCE = "crude-oil"

local function nearest_resource(surface, origin, name)
    local filter = {
        position = origin,
        radius = SEARCH_RADIUS,
        type = "resource",
    }
    if name then filter.name = name end
    local found = surface.find_entities_filtered(filter)
    local best, best_d = nil, math.huge
    for _, ent in pairs(found) do
        local dx = ent.position.x - origin.x
        local dy = ent.position.y - origin.y
        local d = dx * dx + dy * dy
        if d < best_d then
            best_d = d
            best = ent
        end
    end
    return best
end

function Expansion.on_unit_group_finished_gathering(event)
    local group = event.group
    if not (group and group.valid) then return end
    local cmd = group.command
    if not cmd or cmd.type ~= defines.command.build_base then return end

    local surface = group.surface
    if not surface then return end
    local origin = group.position

    local target = nearest_resource(surface, origin, PRIMARY_RESOURCE)
            or nearest_resource(surface, origin, nil)
    if not target then return end

    local new_destination = target.position
    local from = cmd.destination
    Log.debug("expansion", string.format(
        "event=retarget group=%d from=%.0f,%.0f to=%.0f,%.0f resource=%s",
        group.group_number,
        from and from.x or 0, from and from.y or 0,
        new_destination.x, new_destination.y,
        target.name
    ))

    group.set_command({
        type = defines.command.build_base,
        destination = new_destination,
        distraction = defines.distraction.by_anything,
    })
end

return Expansion
