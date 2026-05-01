-- Fish & Chips: the buildable food chain that resets the craving timer like
-- Cuppa Tea does, but without the spoil risk. Fish piggybacks on vanilla
-- raw-fish (hand-caught from water) plus a Greenhouse-grown alternative.
-- Chips are made in the Woodchipper from wood + potatoes.
local Placeholder = require("prototypes.placeholder")

local function basic_item(name, subgroup, order, stack)
    return {
        type = "item",
        name = name,
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = subgroup or "intermediate-product",
        order = order or ("a-z[" .. name .. "]"),
        stack_size = stack or 100,
    }
end

data:extend({
    basic_item("hmfea-potato", "intermediate-product", "a-b-a[hmfea-potato]"),
    basic_item("hmfea-chips",  "intermediate-product", "a-b-b[hmfea-chips]"),
})

-- Fish & Chips is a capsule so the player consumes it via use-on-self;
-- script/cravings.lua catches the use and resets the craving timer.
data:extend({
    {
        type = "capsule",
        name = "hmfea-fish-and-chips",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "intermediate-product",
        order = "a-b-c[hmfea-fish-and-chips]",
        stack_size = 50,
        capsule_action = {
            type = "use-on-self",
            attack_parameters = {
                type = "projectile",
                activation_type = "consume",
                ammo_category = "capsule",
                range = 1,
                cooldown = 30,
                ammo_type = {},
            },
        },
    },
})

data:extend({
    -- Wood -> Potato (greenhouse).
    {
        type = "recipe",
        name = "hmfea-potato",
        enabled = true,
        category = "hmfea-greenhouse",
        energy_required = 4,
        ingredients = { { type = "item", name = "wood", amount = 1 } },
        results = { { type = "item", name = "hmfea-potato", amount = 2 } },
    },
    -- Greenhouse-grown raw-fish (alternative to hand-catching from water).
    {
        type = "recipe",
        name = "hmfea-greenhouse-raw-fish",
        enabled = true,
        category = "hmfea-greenhouse",
        energy_required = 8,
        ingredients = { { type = "item", name = "wood", amount = 2 } },
        results = { { type = "item", name = "raw-fish", amount = 1 } },
    },
    -- Wood + Potato -> Chips (woodchipper).
    {
        type = "recipe",
        name = "hmfea-chips",
        enabled = true,
        category = "hmfea-woodchipper",
        energy_required = 2,
        ingredients = {
            { type = "item", name = "wood",        amount = 1 },
            { type = "item", name = "hmfea-potato", amount = 1 },
        },
        results = { { type = "item", name = "hmfea-chips", amount = 1 } },
    },
    -- Fish + Chips -> Fish & Chips (hand-craft only, like Cuppa Tea).
    {
        type = "recipe",
        name = "hmfea-fish-and-chips",
        enabled = true,
        category = "hmfea-hand-only",
        energy_required = 3,
        ingredients = {
            { type = "item", name = "raw-fish",   amount = 1 },
            { type = "item", name = "hmfea-chips", amount = 1 },
        },
        results = { { type = "item", name = "hmfea-fish-and-chips", amount = 1 } },
    },
})
