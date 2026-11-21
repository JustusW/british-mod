-- Worms as Irish Leprechauns (idea by Mission; art by ingo, "Cartoon Leprechaun"
-- by thejohnsimone, CC BY 4.0, see credits.md). Graphics only: worm stats,
-- ranges, damage, the puddle's damage and slowdown stay vanilla.
--   folded            : crouched in his hole, only the hat shows
--   preparing/folding : popping up / ducking back (same sheet, backward)
--   prepared          : idle with the pot of gold
--   start/end attack  : the throw (16 directions), ending = throw backward
--   death             : on the worm corpses, last frame stays
--   stream            : one tumbling pot of gold per throw
--   puddle            : the acid splash fire shows piles of gold coins
-- One model rendered at big-worm size, scaled per tier like vanilla worms.
local util = require("util")

local DIR = "__hmfea__/graphics/entity/leprechaun/"

local TIERS = {
    small = 0.65,
    medium = 0.83,
    big = 1.0,
    behemoth = 1.2,
}

-- Load ingo's sheet (+ its shadow sheet) and scale it to the tier.
local function scaled(layer, s)
    layer.scale = (layer.scale or 0.5) * s
    if layer.shift then layer.shift = { layer.shift[1] * s, layer.shift[2] * s } end
    return layer
end

local function anim(name, s, opts)
    local function load(path, shadow)
        local o = { scale = 0.5, draw_as_shadow = shadow or nil }
        for k, v in pairs(opts or {}) do o[k] = v end
        return scaled(util.sprite_load(DIR .. path, o), s)
    end
    return { layers = { load(name, false), load(name .. "-shadow", true) } }
end

-- Release points: screen offset (tiles) per direction 0..15.
local function release_points(s)
    local points = require(DIR .. "throw-release-points")
    local params = {}
    for i, p in ipairs(points) do
        table.insert(params, { 0.0625 * (i - 1), { p.screen[1] * s, p.screen[2] * s } })
    end
    return params
end

local function coin_piles(s)
    local meta = require(DIR .. "coin-pile")
    local pics = {}
    for i = 1, 4 do
        table.insert(pics, {
            filename = DIR .. "coin-pile-" .. i .. ".png",
            width = meta.width, height = meta.height,
            shift = { meta.shift[1] * s, meta.shift[2] * s },
            frame_count = 1, scale = 0.5 * s,
        })
    end
    return pics
end

for size, s in pairs(TIERS) do
    local worm = data.raw.turret[size .. "-worm-turret"]
    if worm then
        worm.folded_animation = anim("folded", s)
        worm.preparing_animation = anim("popping-up", s, { run_mode = "forward" })
        worm.folding_animation = anim("popping-up", s, { run_mode = "backward" })
        worm.prepared_animation = anim("idle", s)
        worm.prepared_alternative_animation = nil
        worm.prepared_alternative_chance = nil
        worm.starting_attack_animation = anim("throw", s, { run_mode = "forward" })
        worm.ending_attack_animation = anim("throw", s, { run_mode = "backward" })
        worm.integration = nil  -- the hole and mound are in ingo's frames
        local ap = worm.attack_parameters
        ap.projectile_creation_parameters = release_points(s)
        local delivery = ap.ammo_type and ap.ammo_type.action and ap.ammo_type.action.action_delivery
        if delivery then
            delivery.source_offset = nil
            local stream = data.raw.stream[delivery.stream]
            if stream then
                stream.particle = scaled(util.sprite_load(DIR .. "pot-flying",
                    { frame_count = 15, scale = 0.5, priority = "high" }), s)
                stream.shadow = scaled(util.sprite_load(DIR .. "pot-flying-shadow",
                    { frame_count = 15, scale = 0.5, draw_as_shadow = true }), s)
                stream.particle_loop_frame_count = 15
                stream.spine_animation = nil
                stream.particle_spawn_interval = 1000  -- one pot per throw
                stream.particle_spawn_timeout = 1
                stream.particle_alpha_per_part = 1
                stream.particle_scale_per_part = 1
                stream.particle_start_alpha = 1
                stream.particle_end_alpha = 1
            end
        end
        local fire = data.raw.fire["acid-splash-fire-worm-" .. size]
        if fire then
            fire.pictures = coin_piles(s)
            fire.secondary_pictures = nil
            fire.particle_alpha = 1
        end
        for _, cname in pairs({ worm.corpse, worm.folded_state_corpse }) do
            local corpse = cname and data.raw.corpse[cname]
            if corpse then
                corpse.animation = anim("death", s)
                corpse.decay_animation = nil
                corpse.ground_patch = nil
                corpse.ground_patch_decay = nil
            end
        end
    end
end
