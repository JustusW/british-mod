-- New weapons unique to HMFEA. Vanilla mutations live under prototypes/updates/.
local Placeholder = require("prototypes.placeholder")

-- Custom ammo category so the longbow only accepts arrows.
data:extend({
    {
        type = "ammo-category",
        name = "hmfea-arrow",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "ammo-category",
    },
})

-- Arrow projectile. Light, slow, deals modest physical damage. Vanilla
-- piercing-rounds-magazine-projectile is reused as the visual placeholder
-- so we don't have to ship animations until art lands.
data:extend({
    {
        type = "ammo",
        name = "hmfea-arrow",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        stack_size = 1,
        magazine_size = 1,
        subgroup = "ammo",
        order = "a-a-a[hmfea-arrow]",
        ammo_category = "hmfea-arrow",
        ammo_type = {
            -- Placeholder hitscan damage. Replace with a proper projectile
            -- prototype once arrow art lands.
            action = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "damage",
                            damage = { amount = 10, type = "physical" },
                        },
                    },
                },
            },
        },
    },
})

-- Longbow gun. Moderate cooldown gives the single-shot / manual-reload feel
-- (with arrow stack_size = 1, the player effectively reloads every shot).
data:extend({
    {
        type = "gun",
        name = "hmfea-longbow",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "gun",
        order = "a[basic-clips]-a[hmfea-longbow]",
        stack_size = 5,
        attack_parameters = {
            type = "projectile",
            ammo_category = "hmfea-arrow",
            cooldown = 60,  -- 1s between shots — manual reload feel
            movement_slow_down_factor = 0.7,
            projectile_creation_distance = 1.125,
            range = 25,
            sound = {
                {
                    filename = "__base__/sound/fight/light-gunshot-1.ogg",
                    volume = 0.5,
                },
            },
        },
    },
})
