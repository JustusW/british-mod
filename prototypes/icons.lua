-- Real icons from ingo (graphics/icons 64 px, graphics/technology 256 px,
-- graphics/achievement 128 px). One table instead of editing every prototype
-- file: prototypes keep their placeholder until this runs, and anything not
-- listed here stays a placeholder (release check in design.md).
-- Required at the end of data.lua (mod prototypes) and data-updates.lua
-- (vanilla prototypes the spec reskins). Model credits: credits.md.
local Icons = {}

local ICON = "__hmfea__/graphics/icons/"
local TECH = "__hmfea__/graphics/technology/"
local ACHIEVEMENT = "__hmfea__/graphics/achievement/"

local function set(type_name, name, file, size)
    local proto = data.raw[type_name] and data.raw[type_name][name]
    assert(proto, "icons.lua: no " .. type_name .. " named " .. name)
    proto.icon = file
    proto.icon_size = size
    proto.icons = nil
end

function Icons.apply_mod()
    for _, short in ipairs({
        "clay", "porcelain", "paper", "raw-tea", "tea-leaves", "teacup-clay", "pot-porcelain", "pot-of-tea",
        "kettle", "kettle-of-water", "kettle-of-boiling-water", "spoiled-tea", "potato", "chips", "wand",
        "mr-blobby",
    }) do
        set("item", "hmfea-" .. short, ICON .. short .. ".png", 64)
    end
    for _, short in ipairs({
        "cuppa-tea", "fish-and-chips", "spell-petrificus-totalus", "spell-abra-kadabra", "spell-avada-kedavra",
    }) do
        set("capsule", "hmfea-" .. short, ICON .. short .. ".png", 64)
    end
    set("ammo", "hmfea-arrow", ICON .. "arrow.png", 64)
    set("ammo-category", "hmfea-arrow", ICON .. "arrow.png", 64)
    set("gun", "hmfea-longbow", ICON .. "longbow.png", 64)

    for _, short in ipairs({
        "yer-a-wizard-arry", "spell-petrificus-totalus", "spell-abra-kadabra", "spell-avada-kedavra",
        "philosophers-stone", "truthbomb", "mr-blobby",
    }) do
        set("technology", "hmfea-" .. short, TECH .. short .. ".png", 256)
    end

    set("achievement", "hmfea-you-whimp", ACHIEVEMENT .. "you-whimp.png", 128)
    set("achievement", "hmfea-bloody-uncivilised", ACHIEVEMENT .. "bloody-uncivilised.png", 128)
end

function Icons.apply_vanilla()
    -- Baton (vanilla grenade) and Musket (vanilla submachine gun).
    set("capsule", "grenade", ICON .. "baton.png", 64)
    set("gun", "submachine-gun", ICON .. "musket.png", 64)
end

return Icons
