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
            count = 1000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "military-science-pack",   1 },
                { "chemical-science-pack",   1 },
            },
            time = 30,
        },
        effects = {
            { type = "unlock-recipe", recipe = "hmfea-truthbomb" },
        },
    },
    {
        type = "technology",
        name = "hmfea-mr-blobby",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        prerequisites = { "rocket-silo" },
        unit = {
            -- Designed for ~1000 SPM × 1 hour grind = 60000 science.
            count = 60000,
            ingredients = {
                { "automation-science-pack",  1 },
                { "logistic-science-pack",    1 },
                { "chemical-science-pack",    1 },
                { "production-science-pack",  1 },
                { "utility-science-pack",     1 },
            },
            time = 1,
        },
        effects = {
            { type = "unlock-recipe", recipe = "hmfea-mr-blobby" },
        },
    },
    -- Wand + Spells branch.
    {
        type = "technology",
        name = "hmfea-yer-a-wizard-arry",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        prerequisites = { "automation" },
        unit = {
            count = 100,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
            },
            time = 30,
        },
        effects = {
            { type = "unlock-recipe", recipe = "hmfea-wand" },
        },
    },
    {
        type = "technology",
        name = "hmfea-spell-petrificus-totalus",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        prerequisites = { "hmfea-yer-a-wizard-arry" },
        unit = {
            count = 200,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
            },
            time = 30,
        },
        effects = {
            { type = "unlock-recipe", recipe = "hmfea-spell-petrificus-totalus" },
        },
    },
    {
        type = "technology",
        name = "hmfea-spell-abra-kadabra",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        prerequisites = { "hmfea-spell-petrificus-totalus" },
        unit = {
            count = 400,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
            },
            time = 30,
        },
        effects = {
            { type = "unlock-recipe", recipe = "hmfea-spell-abra-kadabra" },
        },
    },
    {
        type = "technology",
        name = "hmfea-spell-avada-kedavra",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        prerequisites = { "hmfea-spell-abra-kadabra" },
        unit = {
            count = 600,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
                { "military-science-pack",   1 },
            },
            time = 30,
        },
        effects = {
            { type = "unlock-recipe", recipe = "hmfea-spell-avada-kedavra" },
        },
    },
    {
        type = "technology",
        name = "hmfea-philosophers-stone",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        prerequisites = { "chemical-science-pack" },
        unit = {
            count = 500,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
            },
            time = 60,
        },
        -- Effects: none directly. The unlocking is via being a prerequisite
        -- of vanilla tank tech (see prototypes/updates/tank-prereq.lua).
        effects = {},
    },
})
