-- HMFEA technologies. Each prototype lives here; recipe gating + tech tree
-- placement is in this single file so the tree is auditable in one place.
local Placeholder = require("prototypes.placeholder")

data:extend({
    {
        type = "technology",
        name = "hmfea-truthbomb",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        prerequisites = { "explosives", "military-2" },
        unit = {
            count = 250,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "military-science-pack",   1 },
                { "chemical-science-pack",   1 },
            },
            time = 60,
        },
        effects = {
            { type = "unlock-recipe", recipe = "hmfea-truthbomb" },
        },
    },
})
