-- Spoken warnings: Voice.say(target, key) plays hmfea-voice-<key> (the line
-- read by the Peter Yearsley voice) to a player, or to everyone when target is
-- game. Missing clips are skipped. A player hears the same line at most once
-- per COOLDOWN_TICKS, so repeated warnings (pistol rebuke) don't pile up.
local Voice = {}

local COOLDOWN_TICKS = 180

function Voice.say(target, key)
    local path = "hmfea-voice-" .. key
    if not helpers.is_valid_sound_path(path) then return end
    if target == game then
        game.play_sound({ path = path })
        return
    end
    if not (target and target.valid) then return end
    storage.voice = storage.voice or {}
    local id = target.index .. "/" .. key
    local last = storage.voice[id]
    if last and game.tick - last < COOLDOWN_TICKS then return end
    storage.voice[id] = game.tick
    target.play_sound({ path = path })
end

return Voice
