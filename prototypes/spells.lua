-- Wand + spells.
--   - hmfea-wand: flavor item, gates the spell branch via tech prerequisites.
--   - hmfea-spell-petrificus-totalus: thrown capsule. Action chain emits an
--     explosion plus a script trigger ("hmfea-petrify") that script/petrificus.lua
--     handles by moving caught players into a permission-group lockdown and
--     issuing a stop command to caught units.
--   - hmfea-spell-abra-kadabra: use-on-self capsule (via spell_self_capsule).
--     Detonates a radius-25 nuke-style explosion centred on the caster
--     regardless of cursor aim.
--   - hmfea-spell-avada-kedavra: thrown capsule with a single targeted electric
--     strike. A script trigger ("hmfea-avada-kedavra") makes script/avada.lua
--     draw a Tesla turret bolt (hmfea-avada-kedavra-beam, Space Age art copied
--     into graphics/entity/tesla-beam/) from the caster to the target.
local Placeholder = require("prototypes.placeholder")
local util = require("util")

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

-- Self-targeted capsule shape — used by Abra Kadabra so the explosion centres
-- on the caster regardless of where the cursor is aimed.
local function spell_self_capsule(name, target_effects, cooldown)
    return {
        type = "capsule",
        name = name,
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "capsule",
        order = "d[capsule]-z[hmfea]-" .. name,
        stack_size = 10,
        capsule_action = {
            type = "use-on-self",
            attack_parameters = {
                type = "projectile",
                activation_type = "consume",
                ammo_category = "capsule",
                cooldown = cooldown or 60,
                range = 1,
                ammo_type = {
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
-- in script/petrificus.lua finds entities in a 2.5-tile radius and
-- permanently immobilises them — players are moved into the
-- hmfea-petrified-player permission group (denylist on start_walking,
-- begin_mining, craft) and units get a stop-command at uint32_max.
local petrificus_effects = {
    { type = "create-entity", entity_name = "explosion" },
    {
        type = "script",
        effect_id = "hmfea-petrify",
    },
}

-- Abra Kadabra: nuke-style explosion centred on the caster. Wired through
-- spell_self_capsule (use-on-self), so the explosion always lands on the
-- caster regardless of cursor aim.
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

-- Avada Kedavra: single high-damage electric strike at the target tile. The
-- script trigger draws the Tesla bolt from the caster to the target.
local kedavra_effects = {
    { type = "script", effect_id = "hmfea-avada-kedavra" },
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

-- Tesla turret bolt for Avada Kedavra: the Space Age tesla beam graphics,
-- copied into this mod (allowed because info.json's spoiling_required means
-- the player owns Space Age; the space-age mod itself stays disabled, so
-- __space-age__ paths would not resolve). Visual only: the damage comes from
-- the capsule's own area effect.
local BEAM_DIR = "__hmfea__/graphics/entity/tesla-beam/"

local function beam_part(file, opts)
    opts.draw_as_glow = true
    opts.animation_speed = 0.5
    opts.scale = 0.5
    opts.blend_mode = opts.blend_mode or "additive"
    return util.sprite_load(BEAM_DIR .. file, opts)
end

local beam_body = {}
for i = 1, 6 do
    table.insert(beam_body, { layers = {
        beam_part("tesla-body-" .. i, { frame_count = 20, repeat_count = 4 }),
        beam_part("lightning-loop-" .. i, { frame_count = 80 }),
    } })
end

data:extend({
    {
        type = "beam",
        name = "hmfea-avada-kedavra-beam",
        flags = { "not-on-map" },
        hidden = true,
        width = 0.5,
        damage_interval = 20,
        random_target_offset = false,
        action_triggered_automatically = false,
        graphics_set = {
            desired_segment_length = 1,
            randomize_animation_per_segment = true,
            beam = {
                start = beam_part("tesla-beam-START", { frame_count = 20, blend_mode = "normal", flags = { "trilinear-filtering" } }),
                ending = beam_part("tesla-beam-END", { frame_count = 20, blend_mode = "normal", flags = { "trilinear-filtering" } }),
                head = beam_part("tesla-head", { frame_count = 20, flags = { "trilinear-filtering" } }),
                tail = beam_part("tesla-tail", { frame_count = 20, flags = { "trilinear-filtering" } }),
                body = beam_body,
            },
        },
    },
})

data:extend({
    spell_capsule(     "hmfea-spell-petrificus-totalus", petrificus_effects, 25, 90),
    spell_self_capsule("hmfea-spell-abra-kadabra",       kadabra_effects,        180),
    spell_capsule(     "hmfea-spell-avada-kedavra",      kedavra_effects,    35, 60),
})
