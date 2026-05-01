-- EU Flag drops on biter / spitter death. Robot mining of the flag is
-- blocked by cancelling any deconstruction order placed on it.
local Log = require("script.log")
local EuFlag = {}

local FLAG_NAME = "hmfea-eu-flag"

local function is_target(entity)
    if not (entity and entity.valid) then return false end
    local proto = entity.prototype
    if not proto then return false end
    -- Vanilla biter / spitter prototypes have type "unit" with subgroup
    -- "enemies" — but easier to whitelist by name prefix.
    local n = entity.name
    if n == "small-biter" or n == "medium-biter" or n == "big-biter" or n == "behemoth-biter"
        or n == "small-spitter" or n == "medium-spitter" or n == "big-spitter" or n == "behemoth-spitter" then
        return true
    end
    return false
end

function EuFlag.on_entity_died(event)
    local entity = event.entity
    if not is_target(entity) then return end
    local surface = entity.surface
    if not surface then return end
    local pos = entity.position
    local flag = surface.create_entity({
        name = FLAG_NAME,
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

function EuFlag.on_marked_for_deconstruction(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    if entity.name ~= FLAG_NAME then return end
    -- Cancel the deconstruction order so robots leave it alone. The player
    -- can still mine the flag manually (30-second mining_time).
    if entity.cancel_deconstruction then
        entity.cancel_deconstruction(entity.force)
    end
    if event.player_index then
        local player = game.get_player(event.player_index)
        if player and player.valid then
            player.create_local_flying_text({
                text = { "hmfea.eu-flag-no-bots" },
                position = entity.position,
            })
        end
    end
    Log.debug("eu-flag", "event=robot_mining_blocked")
end

return EuFlag
