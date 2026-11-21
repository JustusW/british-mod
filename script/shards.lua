-- Teacup Shards: a drunk Cuppa Tea's clay cup breaks 75% of the time (10% if
-- the player hasn't moved for 10 s). The shards stay in the player's
-- inventory for good: one slot each (stack size 1), put back whenever they
-- leave the main inventory / cursor, destroyed when dropped on the ground.
local Voice = require("script.voice")
local Log = require("script.log")
local Shards = {}

local SHARDS = "hmfea-teacup-shards"
local CUP = "hmfea-teacup-clay"
local STILL_TICKS = 600
local CHANCE_MOVING = 0.75
local CHANCE_STILL = 0.10

local function init_storage()
    storage.shards = storage.shards or {}
    storage.shards.owed = storage.shards.owed or {}
    storage.shards.last_moved = storage.shards.last_moved or {}
end

function Shards.on_init() init_storage() end
function Shards.on_configuration_changed() init_storage() end

function Shards.on_player_changed_position(event)
    if not storage.shards then init_storage() end
    storage.shards.last_moved[event.player_index] = event.tick
end

-- Shards held: main inventory plus the cursor.
local function held(player)
    local main = player.get_inventory(defines.inventory.character_main)
    local n = main and main.get_item_count(SHARDS) or 0
    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read and cursor.name == SHARDS then n = n + cursor.count end
    return n, main
end

function Shards.enforce(player)
    if not (player and player.valid and player.character) then return end
    if not storage.shards then init_storage() end
    local owed = storage.shards.owed[player.index] or 0
    local n, main = held(player)
    if not main then return end
    if n < owed then
        main.insert({ name = SHARDS, count = owed - n })  -- full inventory: retried on the next change
    elseif n > owed then
        main.remove({ name = SHARDS, count = n - owed })
    end
end

local function give_cup(player)
    if player.insert({ name = CUP, count = 1 }) > 0 then return end
    player.surface.spill_item_stack({ position = player.position, stack = { name = CUP, count = 1 } })
end

function Shards.cup_after_drink(player)
    if not (player and player.valid) then return end
    if not storage.shards then init_storage() end
    local last = storage.shards.last_moved[player.index] or 0
    local still = game.tick - last >= STILL_TICKS
    local chance = still and CHANCE_STILL or CHANCE_MOVING
    if math.random() >= chance then
        give_cup(player)
        return
    end
    storage.shards.owed[player.index] = (storage.shards.owed[player.index] or 0) + 1
    Shards.enforce(player)
    player.print({ "hmfea.teacup-broken" })
    Voice.say(player, "teacup-broken")
    Log.debug("shards", string.format("event=cup_broken player=%d still=%s owed=%d",
        player.index, tostring(still), storage.shards.owed[player.index]))
end

function Shards.on_player_dropped_item(event)
    local e = event.entity
    if e and e.valid and e.stack and e.stack.valid_for_read and e.stack.name == SHARDS then
        e.destroy()
    end
    Shards.enforce(game.get_player(event.player_index))
end

function Shards.on_player_event(event)
    Shards.enforce(game.get_player(event.player_index))
end

return Shards
