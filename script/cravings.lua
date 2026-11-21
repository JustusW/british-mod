-- Food cravings (On-Tick debuff). Per-player state machine:
--   Satiated  - duration 5 minutes base + random 0-5 minutes on top
--   Craving   - duration 1 minute
--   Craven    - infinite, until food is eaten
-- Eating Cuppa Tea or Fish & Chips resets the cycle to Satiated.
-- While any player on a force is in Craven, every assembling-machine /
-- furnace / lab / rocket-silo / mining-drill on that force is set inactive
-- (factory shutdown), except the Greenhouse and Woodchipper so food can
-- still be made. Machines built during Craven are paused too. Restored when no Craven player remains on
-- the force; one player eating feeds every Craven player on the force.
-- Reaching Craven also fires the Bloody Uncivilised achievement.
local Log = require("script.log")
local Voice = require("script.voice")
local Cravings = {}

local STAGE_SATIATED = "satiated"
local STAGE_CRAVING = "craving"
local STAGE_CRAVEN = "craven"
local STAGE_DECREPIT = "decrepit"   -- after Emergency Tea: like Satiated, but half speed
local DECREPIT_SPEED_MODIFIER = -0.5

local CRAVING_TICKS = 60 * 60               -- 1 minute @ 60 ticks/s
local SATIATED_BASE_TICKS = 60 * 60 * 5     -- 5 minutes minimum
local SATIATED_RANDOM_RANGE_TICKS = 60 * 60 * 5  -- + random 0-5 minutes on top
local CHECK_INTERVAL = 60                   -- check stage transitions once per second

local SHUTDOWN_TYPES = {
    "assembling-machine",
    "furnace",
    "lab",
    "rocket-silo",
    "mining-drill",
}

local SHUTDOWN_TYPE_SET = {}
for _, t in ipairs(SHUTDOWN_TYPES) do SHUTDOWN_TYPE_SET[t] = true end

-- The food chain keeps running, otherwise Craven with no food in stock
-- could never be ended (Chips need the Woodchipper, potatoes the Greenhouse).
local EXEMPT = {
    ["hmfea-greenhouse"] = true,
    ["hmfea-woodchipper"] = true,
}

local FOOD_ITEMS = {
    ["hmfea-cuppa-tea"] = true,
    ["hmfea-emergency-tea"] = true,
    ["hmfea-fish-and-chips"] = true,
}

-- A drunk Cuppa Tea gives its Teacup (Clay) back; Emergency Tea is a paper cup.
local RETURNS = {
    ["hmfea-cuppa-tea"] = "hmfea-teacup-clay",
}

local function give_back(player, item_name)
    if not (player and player.valid) then return end
    if player.insert({ name = item_name, count = 1 }) > 0 then return end
    player.surface.spill_item_stack({ position = player.position, stack = { name = item_name, count = 1 } })
end

-- Always-visible stage indicator (label at the top of the screen).
local HUD_NAME = "hmfea-craving-hud"
local HUD_COLORS = {
    [STAGE_SATIATED] = { r = 0.35, g = 0.85, b = 0.35 },
    [STAGE_DECREPIT] = { r = 0.65, g = 0.65, b = 0.65 },
    [STAGE_CRAVING] = { r = 1.0, g = 0.6, b = 0.1 },
    [STAGE_CRAVEN] = { r = 1.0, g = 0.2, b = 0.2 },
}

-- Game alerts in the alert bar while Craving / Craven. Refreshed with the
-- indicator once per second; removed again on Satiated.
local ALERTS = {
    [STAGE_DECREPIT] = { icon = { type = "item", name = "hmfea-emergency-tea" }, message = { "hmfea.alert-decrepit" } },
    [STAGE_CRAVING] = { icon = { type = "item", name = "raw-fish" }, message = { "hmfea.alert-craving" } },
    [STAGE_CRAVEN] = { icon = { type = "virtual", name = "signal-skull" }, message = { "hmfea.alert-craven" } },
}

local function update_alert(player, stage)
    local character = player.character
    if not (character and character.valid) then return end
    player.remove_alert({ entity = character, type = defines.alert_type.custom })
    local alert = ALERTS[stage]
    if alert then
        player.add_custom_alert(character, alert.icon, alert.message, false)
    end
end

-- Half speed while Decrepit. Re-applied every refresh so a respawned
-- character gets it too; reset only if this mod set it.
local function update_speed(player, stage)
    local character = player.character
    if not (character and character.valid) then return end
    storage.cravings.slowed = storage.cravings.slowed or {}
    if stage == STAGE_DECREPIT then
        character.character_running_speed_modifier = DECREPIT_SPEED_MODIFIER
        storage.cravings.slowed[player.index] = true
    elseif storage.cravings.slowed[player.index] then
        character.character_running_speed_modifier = 0
        storage.cravings.slowed[player.index] = nil
    end
end

local function update_hud(player, entry, tick)
    if not (player and player.valid and player.connected and entry and entry.stage) then return end
    update_alert(player, entry.stage)
    update_speed(player, entry.stage)
    local label = player.gui.top[HUD_NAME]
    if not (label and label.valid) then
        label = player.gui.top.add({ type = "label", name = HUD_NAME })
        label.style.font = "default-large-bold"
    end
    if entry.stage == STAGE_CRAVING and entry.stage_ends_at then
        local seconds = math.max(0, math.ceil((entry.stage_ends_at - tick) / 60))
        label.caption = { "hmfea.craving-hud-craving", seconds }
    else
        label.caption = { "hmfea.craving-hud-" .. entry.stage }
    end
    label.style.font_color = HUD_COLORS[entry.stage]
end

local function init_storage()
    storage = storage or {}
    storage.cravings = storage.cravings or {}
    storage.cravings.players = storage.cravings.players or {}
    storage.cravings.force_shutdowns = storage.cravings.force_shutdowns or {}
end

local function satiated_duration_ticks()
    return SATIATED_BASE_TICKS + math.random(0, SATIATED_RANDOM_RANGE_TICKS)
end

local function force_has_craven_player(force)
    for _, p in pairs(force.players) do
        local entry = storage.cravings.players[p.index]
        if entry and entry.stage == STAGE_CRAVEN then
            return true
        end
    end
    return false
end

local function shutdown_force(force)
    if storage.cravings.force_shutdowns[force.index] then return end
    local affected = {}
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered({
            force = force,
            type = SHUTDOWN_TYPES,
        })) do
            -- 2.1: LuaEntity.active is read-only; scripts pause machines via
            -- disabled_by_script. Leave ones another script already paused.
            if not entity.disabled_by_script and not EXEMPT[entity.name] then
                entity.disabled_by_script = true
                table.insert(affected, entity)
            end
        end
    end
    storage.cravings.force_shutdowns[force.index] = affected
    Log.debug("craving", string.format(
        "event=force_shutdown force=%d entities=%d",
        force.index, #affected
    ))
end

local function restore_force(force)
    local affected = storage.cravings.force_shutdowns[force.index]
    if not affected then return end
    local restored = 0
    for _, entity in pairs(affected) do
        if entity.valid then
            entity.disabled_by_script = false
            restored = restored + 1
        end
    end
    storage.cravings.force_shutdowns[force.index] = nil
    Log.debug("craving", string.format(
        "event=force_restored force=%d entities=%d",
        force.index, restored
    ))
end

local function update_force_shutdown(force)
    if force_has_craven_player(force) then
        shutdown_force(force)
    else
        restore_force(force)
    end
end

local function set_stage(player_index, stage, current_tick)
    local entry = storage.cravings.players[player_index]
    if not entry then
        entry = {}
        storage.cravings.players[player_index] = entry
    end
    local prev_stage = entry.stage
    entry.stage = stage
    if stage == STAGE_SATIATED or stage == STAGE_DECREPIT then
        entry.stage_ends_at = current_tick + satiated_duration_ticks()
    elseif stage == STAGE_CRAVING then
        entry.stage_ends_at = current_tick + CRAVING_TICKS
    else
        entry.stage_ends_at = nil
    end

    update_hud(game.get_player(player_index), entry, current_tick)

    if prev_stage and prev_stage ~= stage then
        Log.debug("craving", string.format(
            "event=stage_change player=%d from=%s to=%s",
            player_index, prev_stage, stage
        ))
    end

    if stage == STAGE_CRAVEN then
        local player = game.get_player(player_index)
        if player and player.valid then
            update_force_shutdown(player.force)
            player.unlock_achievement("hmfea-bloody-uncivilised")
            Log.debug("craving", string.format(
                "event=achievement_fired name=hmfea-bloody-uncivilised player=%d",
                player_index
            ))
        end
    elseif prev_stage == STAGE_CRAVEN then
        local player = game.get_player(player_index)
        if player and player.valid then
            update_force_shutdown(player.force)
        end
    end
end

function Cravings.on_init()
    init_storage()
end

function Cravings.on_configuration_changed()
    init_storage()
end

function Cravings.on_player_joined_game(event)
    init_storage()
    local entry = storage.cravings.players[event.player_index]
    if not entry then
        set_stage(event.player_index, STAGE_SATIATED, game.tick)
    elseif entry.stage == STAGE_CRAVEN then
        -- Catch-up: a player who joins while their stored state is Craven
        -- gets the achievement they would have earned earlier in the run.
        local player = game.get_player(event.player_index)
        if player and player.valid then
            player.unlock_achievement("hmfea-bloody-uncivilised")
        end
    end
end

function Cravings.on_tick(event)
    if not storage.cravings then init_storage() end
    if event.tick % CHECK_INTERVAL ~= 0 then return end

    for _, player in pairs(game.connected_players) do
        local entry = storage.cravings.players[player.index]
        if not entry then
            set_stage(player.index, STAGE_SATIATED, event.tick)
        elseif entry.stage_ends_at and event.tick >= entry.stage_ends_at then
            if entry.stage == STAGE_SATIATED or entry.stage == STAGE_DECREPIT then
                set_stage(player.index, STAGE_CRAVING, event.tick)
                player.print({ "hmfea.craving-start" })
                Voice.say(player, "craving-start")
            elseif entry.stage == STAGE_CRAVING then
                set_stage(player.index, STAGE_CRAVEN, event.tick)
                player.print({ "hmfea.craven-start" })
                Voice.say(player, "craven-start")
            end
        end
        update_hud(player, storage.cravings.players[player.index], event.tick)
    end
end

-- Machines built while their force is Craven are paused as well and join
-- the force's shutdown list, so they are restored with the rest.
function Cravings.on_built(event)
    local e = event.entity
    if not (e and e.valid) then return end
    if not storage.cravings then init_storage() end
    local list = storage.cravings.force_shutdowns[e.force.index]
    if not list then return end
    if not SHUTDOWN_TYPE_SET[e.type] or EXEMPT[e.name] or e.disabled_by_script then return end
    e.disabled_by_script = true
    table.insert(list, e)
end

function Cravings.on_player_used_capsule(event)
    if not (event.item and FOOD_ITEMS[event.item.name]) then return end
    local player = game.get_player(event.player_index)
    if event.item.name == "hmfea-emergency-tea" and player and player.valid then
        player.print({ "hmfea.emergency-tea-insult" })
        Voice.say(player, "emergency-tea-insult")
    end
    if RETURNS[event.item.name] then
        give_back(player, RETURNS[event.item.name])
    end
    -- One eater is enough: every Craven player on the force (online or not)
    -- is fed too, so the force's factory comes back.
    if player and player.valid then
        for _, p in pairs(player.force.players) do
            local entry = storage.cravings.players[p.index]
            if p.index ~= event.player_index and entry and entry.stage == STAGE_CRAVEN then
                set_stage(p.index, STAGE_SATIATED, game.tick)
            end
        end
    end
    -- Emergency Tea leaves the drinker Decrepit (half speed) instead of
    -- Satiated; the insult above replaces the usual "That's better".
    if event.item.name == "hmfea-emergency-tea" then
        set_stage(event.player_index, STAGE_DECREPIT, game.tick)
        return
    end
    set_stage(event.player_index, STAGE_SATIATED, game.tick)
    if player and player.valid then
        player.print({ "hmfea.cravings-reset" })
        Voice.say(player, "cravings-reset")
    end
end

return Cravings
