-- A British line when one of the mod's technologies finishes: printed to the
-- force's players and spoken (hmfea-voice-research-<short>, ingo's clips;
-- missing clips are skipped). Also on scripted research (console, auto-grant).
local Voice = require("script.voice")
local Log = require("script.log")
local ResearchLines = {}

local LINES = {
    ["hmfea-yer-a-wizard-arry"] = "wand",
    ["hmfea-spell-petrificus-totalus"] = "petrificus",
    ["hmfea-spell-abra-kadabra"] = "abra-kadabra",
    ["hmfea-spell-avada-kedavra"] = "avada-kedavra",
    ["hmfea-philosophers-stone"] = "philosophers-stone",
    ["hmfea-truthbomb"] = "truthbomb",
    ["hmfea-mr-blobby"] = "mr-blobby",
    ["railway"] = "hs1",
    ["hmfea-hs2"] = "hs2",
    ["hmfea-hs3"] = "hs3",
}

function ResearchLines.on_research_finished(event)
    local tech = event.research
    local short = tech and tech.valid and LINES[tech.name]
    if not short then return end
    local key = "research-" .. short
    for _, player in pairs(tech.force.players) do
        player.print({ "hmfea." .. key })
        Voice.say(player, key)
    end
    Log.debug("research", string.format("event=line tech=%s", tech.name))
end

return ResearchLines
