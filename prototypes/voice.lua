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
