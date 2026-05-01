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
})
