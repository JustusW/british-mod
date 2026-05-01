-- Gated debug logger. All script-side debug output goes through here, never
-- to chat, and never via direct helpers.write_file calls in feature code.
--
-- Gated on the runtime-global setting `hmfea-debug-logs` (see settings.lua).
-- Output file: script-output/hmfea-debug.txt.
-- Format: "[<subsystem>] tick=N key=value key=value ..."
local Log = {}

function Log.debug(subsystem, line)
    if not settings.global["hmfea-debug-logs"].value then return end
    helpers.write_file(
        "hmfea-debug.txt",
        string.format("[%s] tick=%d %s\n", subsystem, game.tick, line),
        true
    )
end

return Log
