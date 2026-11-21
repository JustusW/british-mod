-- Rambo reskin of biters / spitters and the two nests, with art by ingo
-- (Blender renders, delivered into graphics/entity/). Graphics only: names of
-- prototypes, movement_speed, ranges, damage and cooldowns stay vanilla.
--
-- One Rambo per biter size: small toddler, medium child, big teen, behemoth
-- adult. Sheets are rendered at final size (64 px/tile), so every tier uses
-- scale 0.5 with no per-tier scaling and no tint masks.
--   biters   : run + melee attack (weapon as a club)
--   spitters : run (same sheets) + throw; the acid stream keeps its damage,
--              splash and sticker, but its flying blob is replaced by the
--              tier's tumbling weapon, launched from ingo's release points.
-- Deaths: the die animation sits on the <size>-biter/-spitter-corpse; it plays
-- once (vanilla dying_speed, same frame counts as vanilla: 17 / 15) and the
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
local function rotated(path, frame_count, extra)
    local function opts(shadow)
        local o = {
            frame_count = frame_count,
            direction_count = 16,
            scale = 0.5,
            allow_forced_downscale = true,
            draw_as_shadow = shadow or nil,
        }
        for k, v in pairs(extra or {}) do o[k] = v end
        return o
    end
    return { layers = {
        util.sprite_load(path, opts(false)),
        util.sprite_load(path .. "-shadow", opts(true)),
    } }
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

local function set_death(unit, path, frames)
    local corpse = unit and unit.corpse and data.raw.corpse[unit.corpse]
    if not corpse then return end
    corpse.animation = rotated(path, frames)
    corpse.decay_animation = nil
    corpse.use_decay_layer = false
end

-- ingo's release points are hr pixels (64 px/tile) for directions 0..15.
local function release_points(age)
    local points = require(DIR .. "rambo-thrower/" .. age .. "/release-points")
    local params = {}
    for i, p in ipairs(points) do
        table.insert(params, { 0.0625 * (i - 1), { p[1] / 64, p[2] / 64 } })
    end
    return params
end

for _, tier in ipairs(TIERS) do
    local age = tier.age
    local run_path = DIR .. "rambo/" .. age .. "/rambo-run"

    -- Melee: <size>-biter
    local biter = data.raw.unit[tier.size .. "-biter"]
    if biter then
        biter.run_animation = rotated(run_path, 16)
        biter.distance_per_frame = DISTANCE_PER_FRAME[age]
        biter.attack_parameters.animation =
            rotated(DIR .. "rambo/" .. age .. "/rambo-attack", 11, { animation_speed = 0.4 })
        set_death(biter, DIR .. "rambo/" .. age .. "/rambo-die", 17)
    end

    -- Thrower: <size>-spitter
    local spitter = data.raw.unit[tier.size .. "-spitter"]
    if spitter then
        spitter.run_animation = rotated(run_path, 16)
        spitter.distance_per_frame = DISTANCE_PER_FRAME[age]
        spitter.alternative_attacking_frame_sequence = THROW_SEQUENCE
        local ap = spitter.attack_parameters
        ap.animation = rotated(DIR .. "rambo-thrower/" .. age .. "/rambo-attack", 14)
        ap.warmup = THROW_WARMUP_TICKS
        ap.projectile_creation_parameters = release_points(age)
        set_death(spitter, DIR .. "rambo-thrower/" .. age .. "/rambo-die", 15)

        -- The stream this spitter fires: one tumbling weapon instead of a
        -- jet of acid blobs. Damage, splash and sticker are left as they are.
        local stream_name = ap.ammo_type and ap.ammo_type.action
            and ap.ammo_type.action.action_delivery
            and ap.ammo_type.action.action_delivery.stream
        local stream = stream_name and data.raw.stream[stream_name]
        if stream then
            stream.particle = util.sprite_load(DIR .. "rambo-thrower/" .. age .. "/weapon-flying", {
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
