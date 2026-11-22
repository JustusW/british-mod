-- Rambo reskin of biters / spitters and the two nests, with art by ingo
-- (Blender renders, delivered into graphics/entity/). Graphics only: names of
-- prototypes, movement_speed, ranges, damage and cooldowns stay vanilla.
--
-- One Rambo per biter size: small toddler, medium child, big teen, behemoth
-- adult. Sheets are rendered at final size (64 px/tile), so every tier uses
-- scale 0.5 with no per-tier scaling and no tint masks.
--   biters   : run + melee attack (weapon as a club)
--   spitters : run (same sheets) + throw; the acid stream's flying blob is
--              replaced by the tier's tumbling weapon, launched from ingo's
--              release points. Where it lands the weapon lies on the floor
--              (a corpse, 30 s) instead of an acid puddle; no slowdown sticker.
--              The puddle's damage moves to the impact (about one second of
--              puddle: splash damage per tick x 60), for characters and units
--              only, as the puddle was; buildings take vanilla impact damage.
-- Deaths: the die animation sits on the <size>-biter/-spitter-corpse; it plays
-- once (vanilla dying_speed, 15 frames, shared by biters and spitters) and the
-- last frame stays as the corpse. No decay animation.
local util = require("util")

local DIR = "__hmfea__/graphics/entity/"

local TIERS = {
    { size = "small",    age = "toddler" },
    { size = "medium",   age = "child" },
    { size = "big",      age = "teen" },
    { size = "behemoth", age = "adult" },
}

-- Run cycle stride from ingo's rig (tiles per frame), so feet don't slide.
-- Purely visual: movement_speed is untouched.
local DISTANCE_PER_FRAME = { toddler = 0.123, child = 0.197, teen = 0.268, adult = 0.333 }

-- Colour sheet plus ingo's matching shadow sheet (<path>-shadow, same layout).
-- The thrown weapon lying where it landed: one still per tumble frame, picked
-- at random, so the weapons lie at different angles.
local DROPPED_SECONDS = 30

local function dropped_weapon(age)
    local meta = require(DIR .. "rambo-layered/flying/" .. age .. "/weapon-flying")
    local w, h = meta.width, meta.height
    local variations = {}
    for i = 0, 14 do
        table.insert(variations, {
            filename = DIR .. "rambo-layered/flying/" .. age .. "/weapon-flying-1.png",
            width = w, height = h, x = w * i, y = 0,
            frame_count = 1, direction_count = 1, scale = 0.5,
        })
    end
    local name = "hmfea-dropped-weapon-" .. age
    data:extend({ {
        type = "corpse",
        name = name,
        flags = { "placeable-off-grid", "not-on-map" },
        hidden = true,
        selectable_in_game = false,
        time_before_removal = DROPPED_SECONDS * 60,
        final_render_layer = "corpse",
        animation = variations,
    } })
    return name
end

-- Swap the acid puddle for the dropped weapon, drop the slowdown sticker and
-- put the puddle's damage on the impact.
local function weapon_instead_of_acid(stream, age)
    local fire_name
    for _, action in pairs(stream.initial_action or {}) do
        local effects = action.action_delivery and action.action_delivery.target_effects
        for i = #(effects or {}), 1, -1 do
            local e = effects[i]
            if e.type == "create-fire" then
                fire_name = e.entity_name
                effects[i] = {
                    type = "create-entity",
                    entity_name = dropped_weapon(age),
                    tile_collision_mask = e.tile_collision_mask,
                }
            elseif e.type == "create-sticker" then
                table.remove(effects, i)
            end
        end
    end
    local fire = fire_name and data.raw.fire[fire_name]
    local per_tick = 0
    if fire and fire.on_damage_tick_effect then
        local d = fire.on_damage_tick_effect.action_delivery
        for _, e in pairs(d and d.target_effects or {}) do
            if e.type == "damage" then per_tick = e.damage.amount end
        end
    end
    -- Like the puddle, this extra damage only hits characters and units
    -- ("ground-unit"); buildings keep the vanilla impact damage.
    local area
    for _, action in pairs(stream.initial_action or {}) do
        if action.type == "area" then area = action end
    end
    if area and per_tick > 0 then
        table.insert(stream.initial_action, {
            type = "area",
            radius = area.radius,
            force = area.force,
            ignore_collision_condition = true,
            trigger_target_mask = { "ground-unit" },
            action_delivery = { type = "instant", target_effects = {
                { type = "damage", damage = { amount = per_tick * 60, type = "acid" } },
            } },
        })
    end
    stream.working_sound = nil  -- the acid burn loop
end

-- ingo's layered Rambo (graphics/entity/rambo-layered/<anim>/): one body,
-- shirt mask and shadow per animation, drawn at the age's body_scale; head and
-- weapon per age at final size. Stack order body, shirt, head, weapon (ingo
-- baked the holdouts for that order). Shirt tint per age; adult has none.
local AGES = require(DIR .. "rambo-layered/ages")

local function layered(anim, age, extra)
    local a = AGES[age]
    local base = DIR .. "rambo-layered/" .. anim .. "/"
    local function load(name, scaled, opts)
        local meta = require(base .. name)
        local o = {
            frame_count = meta.frame_count, direction_count = meta.direction_count or 16,
            scale = meta.scale or 0.5, allow_forced_downscale = true,
        }
        for k, v in pairs(opts or {}) do o[k] = v end
        for k, v in pairs(extra or {}) do o[k] = v end
        local layer = util.sprite_load(base .. name, o)
        if scaled then
            layer.scale = layer.scale * a.body_scale
            layer.shift = { layer.shift[1] * a.body_scale, layer.shift[2] * a.body_scale }
        end
        return layer
    end
    local layers = { load("body", true) }
    if a.shirt_tint then table.insert(layers, load("shirt", true, { tint = a.shirt_tint })) end
    table.insert(layers, load("head-" .. age, false))
    table.insert(layers, load("weapon-" .. age, false))
    table.insert(layers, load("shadow", true, { draw_as_shadow = true }))
    return { layers = layers }
end

-- Thrower attack, frames 1-14: 1-6 into the stance, 7 ready, 8-14 the throw,
-- weapon released on frame 12. Speeds are "fraction of the sequence per
-- tick" (vanilla: 6 frames at 1/6*0.4 = 15 ticks). warmup (1-6) and warmup2
-- (7-11) take 15 ticks each = attack warmup 30, so the stream leaves exactly
-- when the attacking sequence shows frame 12.
local THROW_SEQUENCE = {
    warmup_frame_sequence = { 1, 2, 3, 4, 5, 6 },
    warmup2_frame_sequence = { 7, 8, 9, 10, 11, 11 },
    attacking_frame_sequence = { 12, 13, 14, 7 },
    cooldown_frame_sequence = { 7 },
    prepared_frame_sequence = { 7 },
    back_to_walk_frame_sequence = { 6, 5, 4, 3, 2, 1 },

    warmup_animation_speed = 1 / 6 * 0.4,
    attacking_animation_speed = 1 / 4 * 0.4,
    cooldown_animation_speed = 1 / 1 * 0.4 * 0.125,
    prepared_animation_speed = 1 / 1 * 0.5 * 0.4,
    back_to_walk_animation_speed = 1 / 6 * 0.4,
}
local THROW_WARMUP_TICKS = 30

local function set_death(unit, age)
    local corpse = unit and unit.corpse and data.raw.corpse[unit.corpse]
    if not corpse then return end
    corpse.animation = layered("death", age)
    corpse.decay_animation = nil
    corpse.use_decay_layer = false
end

-- ingo's release points are hr pixels (64 px/tile) for directions 0..15.
local function release_points(age)
    local points = require(DIR .. "rambo-layered/throw/release-points-" .. age)
    local params = {}
    for i, p in ipairs(points) do
        table.insert(params, { 0.0625 * (i - 1), { p[1] / 64, p[2] / 64 } })
    end
    return params
end

for _, tier in ipairs(TIERS) do
    local age = tier.age

    -- Melee: <size>-biter
    local biter = data.raw.unit[tier.size .. "-biter"]
    if biter then
        biter.run_animation = layered("run", age)
        biter.distance_per_frame = DISTANCE_PER_FRAME[age]
        biter.attack_parameters.animation =
            layered("club", age, { animation_speed = 0.4 })
        set_death(biter, age)
    end

    -- Thrower: <size>-spitter
    local spitter = data.raw.unit[tier.size .. "-spitter"]
    if spitter then
        spitter.run_animation = layered("run", age)
        spitter.distance_per_frame = DISTANCE_PER_FRAME[age]
        spitter.alternative_attacking_frame_sequence = THROW_SEQUENCE
        local ap = spitter.attack_parameters
        ap.animation = layered("throw", age)
        ap.warmup = THROW_WARMUP_TICKS
        ap.projectile_creation_parameters = release_points(age)
        set_death(spitter, age)

        -- The stream this spitter fires: one tumbling weapon instead of a
        -- jet of acid blobs; it lands on the floor instead of an acid puddle.
        local stream_name = ap.ammo_type and ap.ammo_type.action
            and ap.ammo_type.action.action_delivery
            and ap.ammo_type.action.action_delivery.stream
        local stream = stream_name and data.raw.stream[stream_name]
        if stream then
            stream.particle = util.sprite_load(DIR .. "rambo-layered/flying/" .. age .. "/weapon-flying", {
                frame_count = 15,
                scale = 0.5,
                priority = "high",
                animation_speed = 1,
            })
            stream.particle_loop_frame_count = 15
            stream.spine_animation = nil
            stream.shadow = nil
            stream.particle_spawn_interval = 1000  -- one weapon per throw
            stream.particle_spawn_timeout = 1
            stream.particle_alpha_per_part = 1
            stream.particle_scale_per_part = 1
            stream.particle_start_alpha = 1
            weapon_instead_of_acid(stream, age)
        end
    end
end

-- Nests: biter-spawner -> EU Building, spitter-spawner -> Barrack Tent.
-- ingo ships one file per variation (v1..v4); idle 7 frames (loop), death 18
-- frames (last frame = ruin).
local function nest_layers(name, kind, variation, opts)
    local base = DIR .. name .. "/" .. name .. "-" .. kind
    local function with(shadow)
        local o = { scale = 0.5, allow_forced_downscale = true, draw_as_shadow = shadow or nil }
        for k, v in pairs(opts) do o[k] = v end
        return o
    end
    return { layers = {
        util.sprite_load(base .. "-v" .. variation, with(false)),
        util.sprite_load(base .. "-shadow-v" .. variation, with(true)),
    } }
end

local function nest_idle(name, variation)
    return nest_layers(name, "idle", variation, { frame_count = 7, animation_speed = 0.18 })
end

local function nest_death(name, variation)
    return nest_layers(name, "death", variation, { frame_count = 18, direction_count = 1 })
end

local NESTS = {
    { spawner = "biter-spawner",   art = "eu-building" },
    { spawner = "spitter-spawner", art = "barrack-tent" },
}

for _, nest in ipairs(NESTS) do
    local spawner = data.raw["unit-spawner"][nest.spawner]
    if spawner then
        local animations = {}
        for v = 1, 4 do table.insert(animations, nest_idle(nest.art, v)) end
        spawner.graphics_set = spawner.graphics_set or {}
        spawner.graphics_set.animations = animations
        spawner.icon = "__hmfea__/graphics/icons/" .. nest.art .. ".png"
        spawner.icon_size = 64
        spawner.icons = nil

        local corpse = data.raw.corpse[spawner.corpse]
        if corpse then
            local deaths = {}
            for v = 1, 4 do table.insert(deaths, nest_death(nest.art, v)) end
            corpse.animation = deaths
            corpse.decay_animation = nil
            corpse.use_decay_layer = false
        end
    end
end
