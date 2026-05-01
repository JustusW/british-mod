-- Tower of London: 60-second sentence whenever Cuppa Tea spoils in a player's
-- main inventory. The spoil mechanic ships hmfea-spoiled-tea via the item
-- prototype's spoil_result; we watch for that item appearing and apply the
-- sentence by moving the player into a permission group that blocks every
-- input action.
local Log = require("script.log")
local TOL = {}

local SENTENCE_TICKS = 60 * 60      -- 60 seconds @ 60 ticks/s
local JAIL_GROUP_NAME = "hmfea-tower-of-london"

local function init_storage()
    storage = storage or {}
    storage.tower_of_london = storage.tower_of_london or {}
    storage.tower_of_london.sentenced = storage.tower_of_london.sentenced or {}
end

local function get_or_create_jail_group()
    local group = game.permissions.get_group(JAIL_GROUP_NAME)
    if group then return group end
    group = game.permissions.create_group(JAIL_GROUP_NAME)
    -- Disable every input action.
    for _, action_id in pairs(defines.input_action) do
        group.set_allows_action(action_id, false)
    end
    -- Allow chat-related actions so the player can still talk through the
    -- bars. Tower of London is a sentence, not solitary confinement.
    if defines.input_action.write_to_console then
        group.set_allows_action(defines.input_action.write_to_console, true)
    end
    if defines.input_action.toggle_show_entity_info then
        group.set_allows_action(defines.input_action.toggle_show_entity_info, true)
    end
    return group
end

local function sentence(player, current_tick)
    if not (player and player.valid and player.character) then return end
    init_storage()
    local sentenced = storage.tower_of_london.sentenced
    if sentenced[player.index] then return end  -- already sentenced

    local original_group_name = "Default"
    if player.permission_group then
        original_group_name = player.permission_group.name
    end

    sentenced[player.index] = {
        expiry = current_tick + SENTENCE_TICKS,
        original_group = original_group_name,
    }

    local jail = get_or_create_jail_group()
    jail.add_player(player)

    player.print({ "hmfea.tower-of-london-sentenced" })
    Log.debug("tower-of-london", string.format(
        "event=sentenced player=%d ticks=%d",
        player.index, SENTENCE_TICKS
    ))
end

local function release(player_index)
    init_storage()
    local entry = storage.tower_of_london.sentenced[player_index]
    if not entry then return end
    local player = game.get_player(player_index)
    if player and player.valid then
        local target_name = entry.original_group or "Default"
        local target = game.permissions.get_group(target_name) or game.permissions.get_group("Default")
        if target then
            target.add_player(player)
        end
        player.print({ "hmfea.tower-of-london-released" })
    end
    storage.tower_of_london.sentenced[player_index] = nil
    Log.debug("tower-of-london", string.format(
        "event=released player=%d",
        player_index
    ))
end

local function check_inventory_for_spoiled_tea(player)
    if not (player and player.valid and player.character) then return end
    local main = player.get_inventory(defines.inventory.character_main)
    if not main then return end
    local count = main.get_item_count("hmfea-spoiled-tea")
    if count > 0 then
        main.remove({ name = "hmfea-spoiled-tea", count = count })
        sentence(player, game.tick)
    end
end

function TOL.on_init()
    init_storage()
end

function TOL.on_configuration_changed()
    init_storage()
end

function TOL.on_player_main_inventory_changed(event)
    check_inventory_for_spoiled_tea(game.get_player(event.player_index))
end

function TOL.on_tick(event)
    if not storage.tower_of_london then init_storage() end
    local sentenced = storage.tower_of_london.sentenced
    if not next(sentenced) then return end
    local tick = event.tick
    for player_index, entry in pairs(sentenced) do
        if tick >= entry.expiry then
            release(player_index)
        end
    end
end

return TOL
