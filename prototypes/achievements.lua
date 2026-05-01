-- Custom achievements. Type "achievement" is the simple no-built-in-trigger
-- variant; we unlock these via LuaPlayer.unlock_achievement from the
-- relevant feature scripts.
local Placeholder = require("prototypes.placeholder")

data:extend({
    {
        type = "achievement",
        name = "hmfea-you-whimp",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        order = "z[hmfea]-a[you-whimp]",
    },
    {
        type = "achievement",
        name = "hmfea-bloody-uncivilised",
        icon = Placeholder.icon_path(),
        icon_size = 64,
        order = "z[hmfea]-b[bloody-uncivilised]",
    },
})
