-- Win condition. Always one path: launch a Mr. Blobby payload via the
-- rocket silo. on_rocket_launched is the trigger; the per-force auto-granted
-- flag (set by script/blobby.lua) decides which victory text plays.
--
-- Audio is unchanged — see design.md "Audio". The victory jingle replacement
-- (if any) ships separately via the utility-sounds override.
local Log = require("script.log")
local Win = {}

local PAYLOAD_NAME = "hmfea-mr-blobby"

local function payload_carries_blobby(rocket)
    if not (rocket and rocket.valid) then return false end
    local inv = rocket.get_inventory(defines.inventory.rocket)
    if not inv then return false end
    return inv.get_item_count(PAYLOAD_NAME) > 0
end

function Win.on_rocket_launched(event)
    local rocket = event.rocket
    if not payload_carries_blobby(rocket) then return end

    local force = rocket.force
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
end

return Win
