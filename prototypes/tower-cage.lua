-- Tower of London cage around a sentenced player (art by ingo): the back bars
-- are drawn under the character, the front bars over it. script/tower-of-london.lua
-- attaches both with the rendering API for the length of the sentence.
local util = require("util")

local function cage_sprite(layer)
    return {
        type = "sprite",
        name = "hmfea-tower-cage-" .. layer,
        filename = "__hmfea__/graphics/entity/tower-cage/cage-" .. layer .. ".png",
        width = 102,
        height = 172,
        scale = 0.5,
        shift = util.by_pixel(0, -24.64),  -- feet of the character = entity position
    }
end

data:extend({ cage_sprite("back"), cage_sprite("front") })
