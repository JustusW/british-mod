-- The player as an English gentleman (suit, monocle, top hat, a candy cane as
-- weapon and pick). Art by ingo, graphics/entity/gentleman/, final size at
-- 64 px/tile -> scale 0.5. One animation set for every armor; no player-colour
-- mask yet (all players look alike until it lands). Graphics only: running
-- speed and everything else about the character stay vanilla.
local util = require("util")

local DIR = "__hmfea__/graphics/entity/gentleman/"

local function anim(name, directions, frames, speed)
    return { layers = { util.sprite_load(DIR .. name, {
        frame_count = frames,
        direction_count = directions,
        animation_speed = speed,
        scale = 0.5,
        allow_forced_downscale = true,
        usage = "player",
    }) } }
end

local character = data.raw.character and data.raw.character["character"]
if character then
    local set = {
        idle = anim("gentleman-idle", 8, 22, 0.15),
        idle_with_gun = anim("gentleman-idle", 8, 22, 0.15),  -- the cane is the gun
        running = anim("gentleman-running", 8, 22, 0.6),
        running_with_gun = anim("gentleman-running-gun", 18, 22, 0.6),
        mining_with_tool = anim("gentleman-mining", 8, 26, 0.9),
    }
    -- Same set without armor and for every armor in the game.
    local armors = {}
    for name in pairs(data.raw.armor or {}) do table.insert(armors, name) end
    local with_armor = util.table.deepcopy(set)
    with_armor.armors = armors
    character.animations = { set, with_armor }
    -- Stride of ingo's run cycle: visual only, so the feet don't slide.
    character.distance_per_frame = 0.091
end

local corpse = data.raw["character-corpse"] and data.raw["character-corpse"]["character-corpse"]
if corpse then
    -- Two lying poses (hat, monocle and cane knocked off), one direction.
    corpse.pictures = { { layers = { util.sprite_load(DIR .. "gentleman-dead", {
        frame_count = 2,
        scale = 0.5,
        usage = "player",
    }) } } }
    corpse.armor_picture_mapping = {}
end
