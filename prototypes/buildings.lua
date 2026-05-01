-- Greenhouse + Woodchipper. Both are placeholder-skinned assembling machines
-- with dedicated recipe categories so only they can run their recipes.
local Placeholder = require("prototypes.placeholder")

-- Recipe categories the buildings own.
data:extend({
    { type = "recipe-category", name = "hmfea-greenhouse" },
    { type = "recipe-category", name = "hmfea-woodchipper" },
})

local function make_machine(name, category, energy)
    return {
        type = "assembling-machine",
        name = name,
        icon = Placeholder.icon_path(),
        icon_size = 64,
        flags = { "placeable-neutral", "placeable-player", "player-creation" },
        minable = { mining_time = 0.5, result = name },
        max_health = 200,
        corpse = "small-remnants",
        collision_box = { { -1.4, -1.4 }, { 1.4, 1.4 } },
        selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
        crafting_categories = { category },
        crafting_speed = 1,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = { pollution = 0 },
        },
        energy_usage = energy or "100kW",
        graphics_set = {
            animation = Placeholder.animation(256),
        },
    }
end

local function make_item(name, place_result, stack)
    return {
        type = "item",
        name = name,
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "production-machine",
        order = "z[" .. name .. "]",
        place_result = place_result,
        stack_size = stack or 50,
    }
end

data:extend({
    make_machine("hmfea-greenhouse",  "hmfea-greenhouse",  "150kW"),
    make_machine("hmfea-woodchipper", "hmfea-woodchipper", "120kW"),
    make_item("hmfea-greenhouse",  "hmfea-greenhouse"),
    make_item("hmfea-woodchipper", "hmfea-woodchipper"),
})

-- Recipes for the buildings themselves (hand-craft from start).
data:extend({
    {
        type = "recipe",
        name = "hmfea-greenhouse",
        enabled = true,
        energy_required = 5,
        ingredients = {
            { type = "item", name = "iron-plate", amount = 10 },
            { type = "item", name = "wood",       amount = 10 },
            { type = "item", name = "stone",      amount = 5 },
        },
        results = { { type = "item", name = "hmfea-greenhouse", amount = 1 } },
    },
    {
        type = "recipe",
        name = "hmfea-woodchipper",
        enabled = true,
        energy_required = 5,
        ingredients = {
            { type = "item", name = "iron-plate",   amount = 8 },
            { type = "item", name = "iron-gear-wheel", amount = 4 },
            { type = "item", name = "wood",         amount = 5 },
        },
        results = { { type = "item", name = "hmfea-woodchipper", amount = 1 } },
    },
})
