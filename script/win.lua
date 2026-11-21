-- Win condition. Always one path: launch a Mr. Blobby payload via the
-- rocket silo. on_cargo_pod_finished_ascending is the trigger; the per-force auto-granted
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

function Win.on_init()
    disable_vanilla_victory()
end

function Win.on_configuration_changed()
    disable_vanilla_victory()
end

-- The silo-script still declares vanilla victory on on_rocket_launched, so
-- keep switching it off there. The payload check happens on the cargo pod.
function Win.on_rocket_launched(event)
    disable_vanilla_victory()
end

-- 2.1: rocket and cargo pod are separate entities and launch triggers moved
-- to on_cargo_pod_finished_ascending. The payload sits in the pod.
function Win.on_cargo_pod_finished_ascending(event)
    if not event.launched_by_rocket then return end
    local pod = event.cargo_pod
    if not (pod and pod.valid) then return end
    disable_vanilla_victory()

    local force = pod.force
    local has_blobby = inventory_has_blobby(pod.get_inventory(defines.inventory.cargo_unit))

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
    game.set_win_ending_info({ title = { key }, message = { key } })
    game.set_game_state({
        game_finished = true,
        player_won = true,
        can_continue = true,
    })
end

return Win
