-- Mr. Blobby: setting + tech auto-grant logic.
--
-- Per design Win condition section:
-- - Setting on (default): research normally.
-- - Setting off (game start, or flipped during run): hmfea-mr-blobby research
--   is auto-granted the moment its prerequisites are fulfilled (or immediately
--   if already met).
-- - Sticky: once auto-granted, storage.blobby.auto_granted[force_index] = true
--   and the consolation message persists for the rest of the run.
-- - You Whimp achievement fires on the first true -> false flip during a run.
local Log = require("script.log")
local Blobby = {}

local SETTING_NAME = "hmfea-enable-mr-blobby"
local TECH_NAME = "hmfea-mr-blobby"

local function init_storage()
    storage = storage or {}
    storage.blobby = storage.blobby or {}
    storage.blobby.pending_auto_grant = storage.blobby.pending_auto_grant or {}
    storage.blobby.auto_granted = storage.blobby.auto_granted or {}
end

local function setting_off()
    return not settings.global[SETTING_NAME].value
end

local function prereqs_satisfied(force, tech)
    if not tech.prerequisites or next(tech.prerequisites) == nil then
        return true
    end
    for prereq_name, _ in pairs(tech.prerequisites) do
        local prereq = force.technologies[prereq_name]
        if not (prereq and prereq.researched) then
            return false
        end
    end
    return true
end

local function grant(force)
    local tech = force.technologies[TECH_NAME]
    if not tech then return false end
    if tech.researched then
        storage.blobby.auto_granted[force.index] = storage.blobby.auto_granted[force.index] or true
        storage.blobby.pending_auto_grant[force.index] = nil
        return false
    end
    tech.researched = true
    storage.blobby.auto_granted[force.index] = true
    storage.blobby.pending_auto_grant[force.index] = nil
    Log.debug("mr-blobby", string.format(
        "event=auto_grant_fired force=%d",
        force.index
    ))
    return true
end

local function evaluate_force(force)
    if not (force and force.valid) then return end
    local tech = force.technologies[TECH_NAME]
    if not tech then return end
    if tech.researched then
        -- Already researched (manually or auto). Mark sticky if the setting is
        -- currently off — otherwise leave it alone.
        if setting_off() then
            storage.blobby.auto_granted[force.index] = storage.blobby.auto_granted[force.index] or true
        end
        return
    end
    if not setting_off() then return end
    if prereqs_satisfied(force, tech) then
        grant(force)
    else
        if not storage.blobby.pending_auto_grant[force.index] then
            storage.blobby.pending_auto_grant[force.index] = true
            Log.debug("mr-blobby", string.format(
                "event=auto_grant_marked force=%d",
                force.index
            ))
        end
    end
end

local function evaluate_all_forces()
    for _, force in pairs(game.forces) do
        evaluate_force(force)
    end
end

function Blobby.on_init()
    init_storage()
    evaluate_all_forces()
end

function Blobby.on_configuration_changed()
    init_storage()
    evaluate_all_forces()
end

function Blobby.on_runtime_mod_setting_changed(event)
    if event.setting ~= SETTING_NAME then return end
    init_storage()
    local now_off = setting_off()
    Log.debug("mr-blobby", string.format(
        "event=setting_changed from=%s to=%s",
        tostring(not now_off), tostring(now_off)
    ))
    if now_off then
        -- First true -> false flip during a running game earns You Whimp.
        if not storage.blobby.ever_flipped_off_during_run then
            storage.blobby.ever_flipped_off_during_run = true
            for _, p in pairs(game.connected_players) do
                p.unlock_achievement("hmfea-you-whimp")
            end
            Log.debug("mr-blobby", "event=achievement_fired name=hmfea-you-whimp")
        end
        evaluate_all_forces()
    end
end

function Blobby.on_research_finished(event)
    init_storage()
    if not setting_off() then return end
    local research = event.research
    if not (research and research.force) then return end
    local force = research.force
    if storage.blobby.pending_auto_grant[force.index] then
        local tech = force.technologies[TECH_NAME]
        if tech and not tech.researched and prereqs_satisfied(force, tech) then
            grant(force)
        end
    end
end

function Blobby.on_player_joined_game(event)
    init_storage()
    if storage.blobby.ever_flipped_off_during_run then
        local player = game.get_player(event.player_index)
        if player and player.valid then
            player.unlock_achievement("hmfea-you-whimp")
        end
    end
end

return Blobby
