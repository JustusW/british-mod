-- Win condition. Always one path: launch a Mr. Blobby payload via the
-- rocket silo. on_rocket_launched is the trigger; the per-force auto-granted
-- flag (set by script/blobby.lua) decides which victory text plays.
--
-- Vanilla rocket-launch victory comes from the freeplay scenario's
-- silo-script (core/lualib/silo-script.lua). We switch it off through its
-- official remote interface (silo_script.set_no_victory) and, as a fallback
-- for event-order races, undo any finished state after a non-Blobby launch.
--
-- Audio is unchanged — see design.md "Audio". The victory jingle replacement
-- (if any) ships separately via the utility-sounds override.
local Log = require("script.log")
local Win = {}

local PAYLOAD_NAME = "hmfea-mr-blobby"

local function disable_vanilla_victory()
    if remote.interfaces["silo_script"] and remote.interfaces["silo_script"]["set_no_victory"] then
        remote.call("silo_script", "set_no_victory", true)
    end
end

local function inventory_has_blobby(inv)
    return inv ~= nil and inv.get_item_count(PAYLOAD_NAME) > 0
end

-- 2.1: the rocket's payload sits in the cargo pod attached to the rocket
-- (defines.inventory.rocket no longer exists).
local function payload_carries_blobby(event)
    local rocket = event.rocket
    if rocket and rocket.valid then
        local pod = rocket.attached_cargo_pod
        if pod and pod.valid and inventory_has_blobby(pod.get_inventory(defines.inventory.cargo_unit)) then
            return true
        end
    end
    return false
end

function Win.on_init()
    disable_vanilla_victory()
end

function Win.on_configuration_changed()
    disable_vanilla_victory()
end

function Win.on_rocket_launched(event)
    local rocket = event.rocket
    if not (rocket and rocket.valid) then return end
    disable_vanilla_victory()

    local force = rocket.force
    local has_blobby = payload_carries_blobby(event)

    if not has_blobby then
        -- Fallback: if vanilla still declared victory, undo it. Only
        -- Mr. Blobby launches count as victory.
        game.reset_game_state()
        Log.debug("mr-blobby", string.format(
            "event=win_suppressed force=%d reason=no-blobby",
            force.index
        ))
        for _, p in pairs(force.players) do
            if p.connected then
                p.print({ "hmfea.win-suppressed" })
            end
        end
        return
    end

    local auto_granted = storage.blobby
        and storage.blobby.auto_granted
        and storage.blobby.auto_granted[force.index]
    local variant = auto_granted and "consolation" or "standard"
    local key = auto_granted and "hmfea.blobby-consolation" or "hmfea.blobby-victory"

    Log.debug("mr-blobby", string.format(
        "event=win_text variant=%s force=%d",
        variant, force.index
    ))

    for _, p in pairs(force.players) do
        if p.connected then
            p.print({ key })
        end
    end

    game.reset_game_state()
    game.set_game_state({
        game_finished = true,
        player_won = true,
        victorious_force = force,
        can_continue = true,
    })
end

return Win
