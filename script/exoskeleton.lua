-- "Officers don't run." — equipping an exoskeleton kills the player.
-- Enforced via a single helper called from every relevant hook so save loads
-- and mid-game mod adds also enforce the rule retroactively.
local Log = require("script.log")
local Exoskeleton = {}

local FORBIDDEN_EQUIPMENT = "exoskeleton-equipment"

local function has_exoskeleton(player)
    if not player or not player.valid then return false end
    if not player.character then return false end
    local armor_inv = player.get_inventory(defines.inventory.character_armor)
    if not armor_inv then return false end
    local armor = armor_inv[1]
    if not armor or not armor.valid_for_read then return false end
    local grid = armor.grid
    if not grid then return false end
    for _, eq in pairs(grid.equipment) do
        if eq.name == FORBIDDEN_EQUIPMENT then
            return true
        end
    end
    return false
end

local function enforce_no_exoskeleton(player)
    if not (player and player.valid and player.character) then return end
    if has_exoskeleton(player) then
        player.print({ "hmfea.officers-dont-run" })
        Log.debug("exoskeleton", string.format(
            "event=killed player=%d",
            player.index
        ))
        player.character.die()
    end
end

local function enforce_all()
    for _, player in pairs(game.connected_players) do
        enforce_no_exoskeleton(player)
    end
end

function Exoskeleton.on_init()
    -- No connected players on a fresh save, so this is a no-op there. The
    -- call is harmless and keeps the lifecycle parallel.
    enforce_all()
end

function Exoskeleton.on_configuration_changed()
    -- Mid-game mod-add or update: catch any player who is already wearing one.
    enforce_all()
end

function Exoskeleton.on_player_joined_game(event)
    enforce_no_exoskeleton(game.get_player(event.player_index))
end

function Exoskeleton.on_player_armor_inventory_changed(event)
    enforce_no_exoskeleton(game.get_player(event.player_index))
end

return Exoskeleton
