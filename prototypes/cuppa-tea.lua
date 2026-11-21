-- Cuppa Tea recipe chain. Hand-craft only on the final item; intermediates use
-- normal crafting / smelting categories. Spoils on a 5-minute timer (placeholder)
-- to a hmfea-spoiled-tea sentinel item; the Tower of London handler in
-- script/tower-of-london.lua hooks the spoil event.
local Placeholder = require("prototypes.placeholder")

-- Recipe category dedicated to the final Cuppa Tea craft. Only the player
-- character is given this category (see prototypes/updates/character.lua) so
-- no assembler can mass-produce tea.
data:extend({
    {
        type = "recipe-category",
        name = "hmfea-hand-only",
    },
})

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

-- Items
data:extend({
    basic_item("hmfea-clay",                  "intermediate-product", "a-a-a[hmfea-clay]"),
    basic_item("hmfea-porcelain",             "intermediate-product", "a-a-b[hmfea-porcelain]"),
    basic_item("hmfea-paper",                 "intermediate-product", "a-a-c[hmfea-paper]"),
    basic_item("hmfea-raw-tea",               "raw-resource",         "a-a-d[hmfea-raw-tea]"),
    basic_item("hmfea-tea-leaves",            "intermediate-product", "a-a-e[hmfea-tea-leaves]"),
    basic_item("hmfea-teacup-clay",           "intermediate-product", "a-a-f[hmfea-teacup-clay]"),
    basic_item("hmfea-pot-porcelain",         "intermediate-product", "a-a-g[hmfea-pot-porcelain]"),
    basic_item("hmfea-pot-of-tea",            "intermediate-product", "a-a-h[hmfea-pot-of-tea]"),
    basic_item("hmfea-kettle",                "intermediate-product", "a-a-i[hmfea-kettle]"),
    basic_item("hmfea-kettle-of-water",       "intermediate-product", "a-a-j[hmfea-kettle-of-water]"),
    basic_item("hmfea-kettle-of-boiling-water","intermediate-product","a-a-k[hmfea-kettle-of-boiling-water]"),
})

-- Teacup Shards: what a broken cup leaves in the player's inventory for good
-- (script/shards.lua). Stack size 1, so each takes a slot. Icon by ingo.
data:extend({
    {
        type = "item",
        name = "hmfea-teacup-shards",
        icon = "__hmfea__/graphics/icons/teacup-shards.png",
        icon_size = 64,
        subgroup = "intermediate-product",
        order = "a-a-x[hmfea-teacup-shards]",
        stack_size = 1,
    },
})

-- Spoiled tea sentinel: terminal item that does not itself spoil and has no
-- recipe. Holding it serves as evidence of the spoil for replay / debugging.
data:extend({
    {
        type = "item",
        name = "hmfea-spoiled-tea",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "intermediate-product",
        order = "a-a-y[hmfea-spoiled-tea]",
        stack_size = 100,
    },
})

-- Cuppa Tea: the final, spoiling consumable. Hand-craft only via the
-- hmfea-hand-only recipe category. Capsule type so the player consumes it
-- via the use-on-self mechanic — script/cravings.lua catches the use and
-- resets the food-craving state.
data:extend({
    {
        type = "capsule",
        name = "hmfea-cuppa-tea",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "intermediate-product",
        order = "a-a-z[hmfea-cuppa-tea]",
        stack_size = 50,
        spoil_ticks = 60 * 60 * 5,  -- 5 minutes (placeholder, tune in playtest)
        spoil_result = "hmfea-spoiled-tea",
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

-- Recipes for the chain. Smelting recipes use category "smelting"; everything
-- else uses default "crafting"; the final cuppa-tea uses "hmfea-hand-only".
data:extend({
    -- Stone -> Clay. Plain crafting: vanilla stone-brick already smelts stone,
    -- and a furnace picks one recipe per input item.
    {
        type = "recipe",
        name = "hmfea-clay",
        enabled = true,
        energy_required = 3.2,
        ingredients = { { type = "item", name = "stone", amount = 1 } },
        results = { { type = "item", name = "hmfea-clay", amount = 1 } },
    },
    -- Clay + Coal -> Porcelain. Plain crafting: base furnaces take only one
    -- input item, so a two-ingredient smelting recipe could never run.
    {
        type = "recipe",
        name = "hmfea-porcelain",
        enabled = true,
        energy_required = 6.4,
        ingredients = {
            { type = "item", name = "hmfea-clay", amount = 1 },
            { type = "item", name = "coal",       amount = 1 },
        },
        results = { { type = "item", name = "hmfea-porcelain", amount = 1 } },
    },
    -- Wood -> Paper. Made in the Greenhouse (hmfea-greenhouse category).
    {
        type = "recipe",
        name = "hmfea-paper",
        enabled = true,
        categories = { "hmfea-greenhouse" },
        energy_required = 2,
        ingredients = { { type = "item", name = "wood", amount = 2 } },
        results = { { type = "item", name = "hmfea-paper", amount = 1 } },
    },
    -- Raw tea: grown in the Greenhouse from wood as a starter cutting.
    {
        type = "recipe",
        name = "hmfea-raw-tea",
        enabled = true,
        categories = { "hmfea-greenhouse" },
        energy_required = 5,
        ingredients = { { type = "item", name = "wood", amount = 1 } },
        results = { { type = "item", name = "hmfea-raw-tea", amount = 1 } },
    },
    -- Paper + Raw tea -> Tea Leaves
    {
        type = "recipe",
        name = "hmfea-tea-leaves",
        enabled = true,
        energy_required = 1,
        ingredients = {
            { type = "item", name = "hmfea-paper",   amount = 1 },
            { type = "item", name = "hmfea-raw-tea", amount = 1 },
        },
        results = { { type = "item", name = "hmfea-tea-leaves", amount = 1 } },
    },
    -- Teacup made from Clay
    {
        type = "recipe",
        name = "hmfea-teacup-clay",
        enabled = true,
        energy_required = 1,
        ingredients = { { type = "item", name = "hmfea-clay", amount = 2 } },
        results = { { type = "item", name = "hmfea-teacup-clay", amount = 1 } },
    },
    -- Pot (Porcelain) made from Porcelain
    {
        type = "recipe",
        name = "hmfea-pot-porcelain",
        enabled = true,
        energy_required = 1,
        ingredients = { { type = "item", name = "hmfea-porcelain", amount = 2 } },
        results = { { type = "item", name = "hmfea-pot-porcelain", amount = 1 } },
    },
    -- Pot of Tea: Pot (Porcelain) + Tea Leaves (the "boiling" step is implicit)
    {
        type = "recipe",
        name = "hmfea-pot-of-tea",
        enabled = true,
        energy_required = 2,
        ingredients = {
            { type = "item", name = "hmfea-pot-porcelain", amount = 1 },
            { type = "item", name = "hmfea-tea-leaves",    amount = 1 },
        },
        results = { { type = "item", name = "hmfea-pot-of-tea", amount = 1 } },
    },
    -- Kettle: iron + copper
    {
        type = "recipe",
        name = "hmfea-kettle",
        enabled = true,
        energy_required = 2,
        ingredients = {
            { type = "item", name = "iron-plate",   amount = 2 },
            { type = "item", name = "copper-plate", amount = 1 },
        },
        results = { { type = "item", name = "hmfea-kettle", amount = 1 } },
    },
    -- Kettle of Water: kettle filled from a vanilla water-barrel (plain
    -- crafting, so it can be hand-crafted). The empty barrel comes back.
    {
        type = "recipe",
        name = "hmfea-kettle-of-water",
        enabled = true,
        energy_required = 1,
        ingredients = {
            { type = "item", name = "hmfea-kettle", amount = 1 },
            { type = "item", name = "water-barrel", amount = 1 },
        },
        results = {
            { type = "item", name = "hmfea-kettle-of-water", amount = 1 },
            { type = "item", name = "barrel",                amount = 1 },
        },
        main_product = "hmfea-kettle-of-water",
    },
    -- Kettle of Boiling Water: smelt the kettle of water in a furnace
    {
        type = "recipe",
        name = "hmfea-kettle-of-boiling-water",
        enabled = true,
        categories = { "smelting" },
        energy_required = 6.4,
        ingredients = { { type = "item", name = "hmfea-kettle-of-water", amount = 1 } },
        results = { { type = "item", name = "hmfea-kettle-of-boiling-water", amount = 1 } },
    },
    -- Cuppa Tea: hand-craft only. Combines Teacup + Pot of Tea + Kettle of
    -- Boiling Water. The output spoils on a 5-minute timer (see item).
    {
        type = "recipe",
        name = "hmfea-cuppa-tea",
        enabled = true,
        categories = { "hmfea-hand-only" },
        energy_required = 5,
        ingredients = {
            { type = "item", name = "hmfea-teacup-clay",            amount = 1 },
            { type = "item", name = "hmfea-pot-of-tea",             amount = 1 },
            { type = "item", name = "hmfea-kettle-of-boiling-water",amount = 1 },
        },
        results = { { type = "item", name = "hmfea-cuppa-tea", amount = 1 } },
    },
})

-- Emergency Teatime: the guaranteed way out of Craven. Hand-craft only, 60 s,
-- 10 wood -> 1 Emergency Tea (paper cup: ends cravings like Cuppa Tea, spoils
-- like it, but gives no teacup back). script/teatime.lua plays an annoying
-- sound for the whole craft.
data:extend({
    {
        type = "capsule",
        name = "hmfea-emergency-tea",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "intermediate-product",
        order = "a-a-z[hmfea-emergency-tea]",
        stack_size = 50,
        spoil_ticks = 60 * 60 * 5,  -- same as Cuppa Tea
        spoil_result = "hmfea-spoiled-tea",
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
    {
        type = "recipe",
        name = "hmfea-emergency-teatime",
        enabled = true,
        categories = { "hmfea-hand-only" },
        energy_required = 60,
        ingredients = { { type = "item", name = "wood", amount = 10 } },
        results = { { type = "item", name = "hmfea-emergency-tea", amount = 1 } },
        order = "a-a-z[hmfea-emergency-teatime]",
    },
})
