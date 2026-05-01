-- Hidden electric-energy-interface used to drain the Craven player's force
-- power network. Spawned at the player's position when they enter the Craven
-- stage, destroyed when they next eat. The drain is best-effort — it only
-- bites if there is a powered network nearby.
local Placeholder = require("prototypes.placeholder")

data:extend({
    {
        type = "electric-energy-interface",
        name = "hmfea-craven-drain",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        flags = { "not-on-map", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "hide-alt-info" },
        selectable_in_game = false,
        collision_box = { { -0.05, -0.05 }, { 0.05, 0.05 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        collision_mask = { layers = {} },
        energy_source = {
            type = "electric",
            usage_priority = "primary-input",
            buffer_capacity = "1MJ",
            input_flow_limit = "1TW",
            output_flow_limit = "0W",
        },
        energy_production = "0W",
        energy_usage = "999GW",
        picture = {
            filename = "__hmfea__/graphics/placeholder/checkerboard-64.png",
            priority = "extra-high",
            width = 64,
            height = 64,
        },
    },
})
