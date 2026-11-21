-- Emergency Teatime: while a player is hand-crafting hmfea-emergency-teatime,
-- an annoying sound plays to them once a second. Placeholder until the clip
-- (ASSETS A5, sound prototype hmfea-emergency-teatime) exists.
local Log = require("script.log")
local Teatime = {}

local RECIPE = "hmfea-emergency-teatime"
local CLIP = "hmfea-emergency-teatime"
local PLACEHOLDER = "utility/cannot_build"
local INTERVAL = 60

local function crafting_teatime(player)
    if not (player.character and player.crafting_queue_size > 0) then return false end
    if player.crafting_queue_progress <= 0 then return false end
    local first = player.crafting_queue[1]
    return first ~= nil and first.recipe == RECIPE
end

function Teatime.on_tick(event)
    if event.tick % INTERVAL ~= 0 then return end
    storage.teatime = storage.teatime or {}
    local path = helpers.is_valid_sound_path(CLIP) and CLIP or PLACEHOLDER
    for _, player in pairs(game.connected_players) do
        if crafting_teatime(player) then
            player.play_sound({ path = path })
            if not storage.teatime[player.index] then
                storage.teatime[player.index] = true
                Log.debug("teatime", string.format("event=crafting player=%d", player.index))
            end
        else
            storage.teatime[player.index] = nil
        end
    end
end

return Teatime
