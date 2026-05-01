data:extend({
    {
        type = "recipe",
        name = "hmfea-medkit",
        enabled = true,
        energy_required = 1800,
        ingredients = {},
        results = { { type = "item", name = "hmfea-medkit", amount = 1 } },
        icon = "__hmfea__/graphics/item_icons/medkit.png",
    },
    {
        type = "recipe",
        name = "hmfea-longbow",
        enabled = true,
        energy_required = 5,
        ingredients = { { type = "item", name = "wood", amount = 10 } },
        results = { { type = "item", name = "hmfea-longbow", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-arrow",
        enabled = true,
        energy_required = 1,
        ingredients = {
            { type = "item", name = "wood", amount = 1 },
            { type = "item", name = "stone", amount = 1 },
        },
        results = { { type = "item", name = "hmfea-arrow", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-truthbomb",
        enabled = false,  -- unlocked by hmfea-truthbomb research
        energy_required = 30,
        ingredients = {
            { type = "item", name = "explosives",  amount = 50 },
            { type = "item", name = "iron-plate",  amount = 100 },
            { type = "item", name = "engine-unit", amount = 10 },
        },
        results = { { type = "item", name = "hmfea-truthbomb", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-mr-blobby",
        enabled = false,  -- unlocked by hmfea-mr-blobby research (or by setting flip)
        energy_required = 60,
        ingredients = {
            { type = "item", name = "low-density-structure", amount = 100 },
            { type = "item", name = "processing-unit",       amount = 200 },
            { type = "item", name = "plastic-bar",           amount = 500 },
        },
        results = { { type = "item", name = "hmfea-mr-blobby", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-wand",
        enabled = false,
        energy_required = 5,
        ingredients = {
            { type = "item", name = "wood",        amount = 1 },
            { type = "item", name = "iron-stick",  amount = 1 },
        },
        results = { { type = "item", name = "hmfea-wand", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-spell-petrificus-totalus",
        enabled = false,
        energy_required = 5,
        ingredients = {
            { type = "item", name = "hmfea-wand",  amount = 1 },
            { type = "item", name = "stone",       amount = 5 },
        },
        results = { { type = "item", name = "hmfea-spell-petrificus-totalus", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-spell-abra-kadabra",
        enabled = false,
        energy_required = 10,
        ingredients = {
            { type = "item", name = "hmfea-wand",  amount = 1 },
            { type = "item", name = "explosives",  amount = 5 },
        },
        results = { { type = "item", name = "hmfea-spell-abra-kadabra", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-spell-avada-kedavra",
        enabled = false,
        energy_required = 5,
        ingredients = {
            { type = "item", name = "hmfea-wand",        amount = 1 },
            { type = "item", name = "copper-cable",      amount = 10 },
        },
        results = { { type = "item", name = "hmfea-spell-avada-kedavra", amount = 1 } },
    },
})
