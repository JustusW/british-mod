-- Truthbomb script trigger handler. Detonation prototype emits a script
-- trigger effect; we log it. Audio (Michael Caine line) is TBD until a sound
-- prototype lands; the placeholder is the explosion graphics + log entry.
local Log = require("script.log")
local Truthbomb = {}

function Truthbomb.on_script_trigger_effect(event)
    if event.effect_id ~= "hmfea-truthbomb-detonated" then return end
    local x = (event.target_position and event.target_position.x) or
              (event.source_position and event.source_position.x) or 0
    local y = (event.target_position and event.target_position.y) or
              (event.source_position and event.source_position.y) or 0
    Log.debug("truthbomb", string.format(
        "event=detonated x=%.1f y=%.1f",
        x, y
    ))
end

return Truthbomb
