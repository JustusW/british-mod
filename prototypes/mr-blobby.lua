-- Mr. Blobby: late-game capsule + rocket payload. The win condition is
-- launching this into space via the rocket silo. Tech is hmfea-mr-blobby
-- (defined in technology.lua), gated as a prerequisite of the research and
-- the launch is hooked in script/blobby.lua.
local Placeholder = require("prototypes.placeholder")

data:extend({
    {
        type = "item",
        name = "hmfea-mr-blobby",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        subgroup = "intermediate-product",
        order = "z[hmfea-mr-blobby]",
        stack_size = 1,
    },
})
