-- Wand + spells. Each spell is a thrown capsule with a placeholder
-- damage / explosion effect; "turn to stone" semantics for Petrificus is
-- TBD pending a proper script handler — current implementation is heavy
-- physical damage as a stand-in.
local Placeholder = require("prototypes.placeholder")

-- Wand is a flavor item gating the spell branch via tech prerequisites.
data:extend({
    {
        type = "item",
        name = "hmfea-wand",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "tool",
        order = "z[hmfea-wand]",
        stack_size = 1,
    },
})

local function spell_capsule(name, target_effects, range, cooldown)
    return {
        type = "capsule",
        name = name,
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "capsule",
        order = "d[capsule]-z[hmfea]-" .. name,
        stack_size = 10,
        capsule_action = {
            type = "throw",
            attack_parameters = {
                type = "projectile",
                activation_type = "throw",
                ammo_category = "capsule",
                cooldown = cooldown or 60,
                projectile_creation_distance = 0.6,
                range = range or 25,
                ammo_type = {
                    target_type = "position",
                    action = {
                        type = "direct",
                        action_delivery = {
                            type = "instant",
                            target_effects = target_effects,
                        },
                    },
                },
            },
        },
    }
end

-- Petrificus Totalus: fires a script trigger at the throw point. Handler
-- in script/petrificus.lua finds entities in a small radius and permanently
-- immobilises them (god controller for player characters, stop-command
-- for units).
local petrificus_effects = {
    { type = "create-entity", entity_name = "explosion" },
    {
        type = "script",
        effect_id = "hmfea-petrify",
    },
}

-- Abra Kadabra: nuke-style explosion centred on the throw point. Player
-- caster usually targets their own feet; we don't enforce that.
local kadabra_effects = {
    { type = "create-entity", entity_name = "big-explosion" },
    { type = "create-entity", entity_name = "big-explosion" },
    {
        type = "nested-result",
        action = {
            type = "area",
            radius = 25,
            action_delivery = {
                type = "instant",
                target_effects = {
                    { type = "damage", damage = { amount = 5000, type = "explosion" } },
                },
            },
        },
    },
}

-- Avada Kedavra: single high-damage electric strike at the target tile.
local kedavra_effects = {
    { type = "create-entity", entity_name = "explosion" },
    {
        type = "nested-result",
        action = {
            type = "area",
            radius = 1.0,
            action_delivery = {
                type = "instant",
                target_effects = {
                    { type = "damage", damage = { amount = 1500, type = "electric" } },
                },
            },
        },
    },
}

data:extend({
    spell_capsule("hmfea-spell-petrificus-totalus", petrificus_effects, 25, 90),
    spell_capsule("hmfea-spell-abra-kadabra",       kadabra_effects,    25, 180),
    spell_capsule("hmfea-spell-avada-kedavra",      kedavra_effects,    35, 60),
})
