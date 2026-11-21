-- Truthbomb script trigger handler. The detonation emits a script trigger
-- effect; we play the voice line (hmfea-truthbomb, ASSETS A2) at the blast
-- and log it.
local Log = require("script.log")
local Truthbomb = {}

function Truthbomb.on_script_trigger_effect(event)
    if event.effect_id ~= "hmfea-truthbomb-detonated" then return end
    local x = (event.target_position and event.target_position.x) or
              (event.source_position and event.source_position.x) or 0
    local y = (event.target_position and event.target_position.y) or
              (event.source_position and event.source_position.y) or 0
    local surface = game.get_surface(event.surface_index)
    if surface and helpers.is_valid_sound_path("hmfea-truthbomb") then
        surface.play_sound({ path = "hmfea-truthbomb", position = { x = x, y = y } })
    end
    Log.debug("truthbomb", string.format(
        "event=detonated x=%.1f y=%.1f",
        x, y
    ))
end

return Truthbomb
