-- Data-stage helper for placeholder graphics.
--
-- Anywhere a prototype's final art isn't ready, use Placeholder.icon() and
-- Placeholder.picture(size) instead of pointing at a missing file or vanilla
-- art. The shared asset lives under graphics/placeholder/ — see
-- design.md "Placeholder graphics" for the policy and release-grep check.
local Placeholder = {}

-- The checkerboard files ship at 64x64 and 256x256 (white / bright purple).
-- Factorio expects icons at icon_size 64 by default, so the 64 file is the
-- canonical icon source.
local ICON_PATH = "__hmfea__/graphics/placeholder/checkerboard-64.png"
local PICTURE_PATH_256 = "__hmfea__/graphics/placeholder/checkerboard-256.png"

-- Return a ready-to-paste { icon = ..., icon_size = ... } pair for prototypes
-- that take a single icon. Use the variant in fields like
-- `data:extend({ { type = "item", icon = Placeholder.icon_path(), icon_size = 64, ... } })`.
function Placeholder.icon_path()
    return ICON_PATH
end

-- Return a Sprite definition table sized for entity sprites / animations.
-- size defaults to 256.
function Placeholder.picture(size)
    size = size or 256
    return {
        filename = (size <= 64) and ICON_PATH or PICTURE_PATH_256,
        priority = "high",
        width = size,
        height = size,
        scale = 1,
    }
end

-- Returns an animation table that just holds still on the placeholder.
function Placeholder.animation(size)
    size = size or 256
    return {
        filename = (size <= 64) and ICON_PATH or PICTURE_PATH_256,
        priority = "high",
        width = size,
        height = size,
        frame_count = 1,
        scale = 1,
    }
end

return Placeholder
