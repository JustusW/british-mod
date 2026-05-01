-- Biter / spitter / nest reskins. Locale + icon overrides; world graphics
-- stay vanilla until proper sprite art lands. Engine prototype names are
-- preserved per the Modifying-vanilla-prototypes rule.
local Placeholder = require("prototypes.placeholder")

local function reskin(type_, name, locale_name)
    local proto = data.raw[type_] and data.raw[type_][name]
    if not proto then return end
    proto.icon = Placeholder.icon_path()
    proto.icon_size = 64
    proto.icons = nil
    if locale_name then
        proto.localised_name = { locale_name }
    end
end

-- Biters -> Rambo soldiers
reskin("unit", "small-biter",     "hmfea.rambo-small")
reskin("unit", "medium-biter",    "hmfea.rambo-medium")
reskin("unit", "big-biter",       "hmfea.rambo-big")
reskin("unit", "behemoth-biter",  "hmfea.rambo-behemoth")

-- Spitters -> Rambo gunners
reskin("unit", "small-spitter",     "hmfea.rambo-spitter-small")
reskin("unit", "medium-spitter",    "hmfea.rambo-spitter-medium")
reskin("unit", "big-spitter",       "hmfea.rambo-spitter-big")
reskin("unit", "behemoth-spitter",  "hmfea.rambo-spitter-behemoth")

-- Nests
reskin("unit-spawner", "biter-spawner",    "hmfea.eu-building")
reskin("unit-spawner", "spitter-spawner",  "hmfea.barrack-tent")
