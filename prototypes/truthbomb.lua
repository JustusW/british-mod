-- Truthbomb (NHS Double Decker Bus): research-gated capsule that produces a
-- massive area explosion. Final pre-Rocket-Silo research. Audio (the Michael
-- Caine line) is TBD — placeholder fires a [truthbomb] script trigger.

-- Projectile entity for the bomb in flight.
data:extend({
    {
        type = "projectile",
        name = "hmfea-truthbomb-projectile",
        flags = { "not-on-map" },
        acceleration = 0,
        -- Art by ingo: the Vote Leave "NHS bus", nose up so the engine's
        -- rotation along the flight lines it up. Model credit: CREDITS.md.
        animation = {
            filename = "__hmfea__/graphics/entity/truthbomb/truthbomb-projectile.png",
            width = 128,
            height = 128,
            frame_count = 1,
            scale = 0.5,
            priority = "high",
        },
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "create-entity",
                        entity_name = "big-explosion",
                    },
                    {
                        type = "nested-result",
                        action = {
                            type = "area",
                            radius = 12,
                            action_delivery = {
                                type = "instant",
                                target_effects = {
                                    {
                                        type = "damage",
                                        damage = { amount = 500, type = "explosion" },
                                    },
                                },
                            },
                        },
                    },
                    {
                        type = "script",
                        effect_id = "hmfea-truthbomb-detonated",
                    },
                },
            },
        },
    },
})

-- Capsule item that throws the bomb.
data:extend({
    {
        type = "capsule",
        name = "hmfea-truthbomb",
        icon = "__hmfea__/graphics/icons/truthbomb.png",
        icon_size = 64,
        subgroup = "capsule",
        order = "d[capsule]-z[hmfea-truthbomb]",
        stack_size = 5,
        capsule_action = {
            type = "throw",
            attack_parameters = {
                type = "projectile",
                activation_type = "throw",
                ammo_category = "capsule",
                cooldown = 60,
                projectile_creation_distance = 0.6,
                range = 25,
                ammo_type = {
                    target_type = "position",
                    action = {
                        type = "direct",
                        action_delivery = {
                            type = "projectile",
                            projectile = "hmfea-truthbomb-projectile",
                            starting_speed = 0.3,
                            max_range = 25,
                        },
                    },
                },
            },
        },
    },
})
