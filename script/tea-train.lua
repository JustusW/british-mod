-- Trains run on tea. Every locomotive has a tea slot (its burner's spent fuel
-- slot) that holds one Cuppa Tea. A tea put into the fuel slots moves into an
-- empty tea slot. In the tea slot it doesn't spoil and lasts 5 minutes of
-- driving; then the empty Teacup stays in the slot (it can't break) until a
-- player takes it out, and only then can the next tea move in. A locomotive
-- with no tea in its tea slot puts its train on strike: the train stops and
-- stays stopped (even with a driver); an automatic train resumes its schedule
-- once every locomotive has tea again.
local Log = require("script.log")
local TeaTrain = {}

local TEA = "hmfea-cuppa-tea"
local CUP = "hmfea-teacup-clay"
local CHECK_TICKS = 10
local DRINK_TICKS = 60 * 60 * 5

local function init_storage()
    storage.tea_train = storage.tea_train or {}
    storage.tea_train.left = storage.tea_train.left or {}        -- unit_number -> drinking ticks left
    storage.tea_train.spoil_left = storage.tea_train.spoil_left or {} -- unit_number -> spoil ticks left (frozen)
    storage.tea_train.strikes = storage.tea_train.strikes or {}
end

local function locomotives_of(train)
    local list = {}
    for _, l in pairs(train.locomotives.front_movers) do table.insert(list, l) end
    for _, l in pairs(train.locomotives.back_movers) do table.insert(list, l) end
    return list
end

local function tea_slot(loco)
    local inv = loco.get_burnt_result_inventory()
    return inv and inv[1]
end

local function has_tea(loco)
    local slot = tea_slot(loco)
    return slot and slot.valid_for_read and slot.name == TEA
end

-- Keep one locomotive's tea slot going; `moving` and `ticks` for the drinking.
local function tend(loco, moving, ticks)
    local slot = tea_slot(loco)
    if not slot then return end
    local id = loco.unit_number
    local st = storage.tea_train
    if not slot.valid_for_read then
        -- Empty slot: take one tea from the fuel slots.
        local fuel = loco.get_fuel_inventory()
        local stack = fuel and fuel.find_item_stack(TEA)
        if stack then
            local spoil_left = stack.spoil_tick > 0 and (stack.spoil_tick - game.tick) or nil
            slot.set_stack({ name = TEA, count = 1 })
            stack.count = stack.count - 1
            st.left[id] = DRINK_TICKS
            st.spoil_left[id] = spoil_left
        end
    end
    -- One tea at a time: any further tea in the fuel slots goes on the ground
    -- (left there it would spoil into the tea slot).
    local fuel = loco.get_fuel_inventory()
    local stack = fuel and fuel.find_item_stack(TEA)
    if stack then
        while stack do
            -- Spill the real stack, so its spoil time carries over.
            loco.surface.spill_item_stack({ position = loco.position, stack = stack })
            stack.clear()
            stack = fuel.find_item_stack(TEA)
        end
        for _, player in pairs(loco.force.connected_players) do
            player.create_local_flying_text({ text = { "hmfea.train-one-tea" }, position = loco.position })
        end
    end
    if slot.valid_for_read and slot.name == TEA then
        -- No spoiling in the tea slot.
        if st.spoil_left[id] and slot.spoil_tick > 0 then
            slot.spoil_tick = game.tick + st.spoil_left[id]
        end
        if moving then
            st.left[id] = (st.left[id] or DRINK_TICKS) - ticks
            if st.left[id] <= 0 then
                slot.set_stack({ name = CUP, count = 1 })
                st.left[id] = nil
                st.spoil_left[id] = nil
                Log.debug("tea-train", string.format("event=tea_finished loco=%d", id))
            end
        end
    end
end

local function start_strike(train)
    local strikes = storage.tea_train.strikes
    if strikes[train.id] then return end
    strikes[train.id] = { train = train, automatic = not train.manual_mode }
    train.manual_mode = true
    train.speed = 0
    local front = train.front_stock
    if front and front.valid then
        for _, player in pairs(front.force.connected_players) do
            player.create_local_flying_text({ text = { "hmfea.train-strike" }, position = front.position, color = { r = 1, g = 0.3, b = 0.3 } })
        end
    end
    Log.debug("tea-train", string.format("event=strike train=%d", train.id))
end

local function end_strike(id, entry)
    storage.tea_train.strikes[id] = nil
    local train = entry.train
    if train and train.valid and entry.automatic then train.manual_mode = false end
    Log.debug("tea-train", string.format("event=strike_over train=%d", id))
end

function TeaTrain.on_init() init_storage() end
function TeaTrain.on_configuration_changed() init_storage() end

function TeaTrain.on_tick(event)
    if not storage.tea_train then init_storage() end
    local strikes = storage.tea_train.strikes
    -- A striking train stays put, driver or not.
    for id, entry in pairs(strikes) do
        local train = entry.train
        if not (train and train.valid) then
            strikes[id] = nil
        elseif train.speed ~= 0 then
            train.speed = 0
        end
    end
    if event.tick % CHECK_TICKS ~= 0 then return end

    -- 2.1: trains are listed by the train manager, not by surface.
    for _, train in pairs(game.train_manager.get_trains({})) do
        local locos = locomotives_of(train)
        if #locos > 0 then
            local moving = train.speed ~= 0
            local all_tea = true
            for _, l in pairs(locos) do
                tend(l, moving, CHECK_TICKS)
                if not has_tea(l) then all_tea = false end
            end
            local entry = strikes[train.id]
            if all_tea then
                if entry then end_strike(train.id, entry) end
            elseif not entry then
                start_strike(train)
            end
        end
    end
end

return TeaTrain
