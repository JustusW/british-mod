-- EU Flag entity. Dropped by biters / spitters on death, mineable by hand
-- only (script blocks robot mining). 30-second mining time is the cost.
local Placeholder = require("prototypes.placeholder")

data:extend({
    {
        type = "simple-entity-with-owner",
        name = "hmfea-eu-flag",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        flags = { "placeable-neutral", "player-creation", "not-rotatable", "not-on-map" },
        max_health = 100,
        collision_box = { { -0.3, -0.3 }, { 0.3, 0.3 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        minable = {
            mining_time = 30,
            results = {},
        },
        picture = {
            filename = "__hmfea__/graphics/placeholder/checkerboard-64.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            scale = 0.5,
        },
        render_layer = "object",
        localised_name = { "hmfea.eu-flag-name" },
        localised_description = { "hmfea.eu-flag-description" },
    },
})
