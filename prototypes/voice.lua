-- One sound prototype per spoken warning (sound/voice/<key>.ogg, rendered by
-- tools/render-voice.py). script/voice.lua plays hmfea-voice-<key>.
local sounds = {}
for _, key in ipairs(require("prototypes.voice-lines")) do
    table.insert(sounds, {
        type = "sound",
        name = "hmfea-voice-" .. key,
        filename = "__hmfea__/sound/voice/" .. key .. ".ogg",
        category = "game-effect",
        volume = 1.0,
    })
end
data:extend(sounds)

-- One-off clips: A1 tank anthem (crowd recording), A2/A4/A5 recorded by ingo.
data:extend({
    { type = "sound", name = "hmfea-god-save-the-king", filename = "__hmfea__/sound/god-save-the-king.ogg", category = "game-effect", volume = 1.0 },
    { type = "sound", name = "hmfea-truthbomb", filename = "__hmfea__/sound/truthbomb.ogg", category = "game-effect", volume = 1.0 },
    { type = "sound", name = "hmfea-get-that-thing-outta-here", filename = "__hmfea__/sound/get-that-thing-outta-here.ogg", category = "game-effect", volume = 1.0 },
    { type = "sound", name = "hmfea-emergency-teatime", filename = "__hmfea__/sound/emergency-teatime.ogg", category = "game-effect", volume = 1.0 },
})
