-- High-speed rail (requirements "High-speed rail"): HS1 is the vanilla Railway
-- research without a locomotive; HS2 unlocks the normal locomotive (max two,
-- enforced in script/hs-trains.lua); HS3 unlocks the HS3 train, which explodes
-- on placement and unlocks the half-speed Steam Locomotive.
-- Runs after prototypes/updates/tea-train.lua, so the copies keep the tea slot.
local util = require("util")

local function remove_unlock(tech, recipe)
    for i = #(tech.effects or {}), 1, -1 do
        local e = tech.effects[i]
        if e.type == "unlock-recipe" and e.recipe == recipe then table.remove(tech.effects, i) end
    end
end

local railway = data.raw.technology["railway"]
if railway then remove_unlock(railway, "locomotive") end

local function tech(name, prereq, count, recipe)
    return {
        type = "technology",
        name = name,
        icon = "__hmfea__/graphics/technology/" .. name:gsub("^hmfea%-", "") .. ".png",  -- ingo
        icon_size = 256,
        prerequisites = { prereq },
        effects = { { type = "unlock-recipe", recipe = recipe } },
        unit = {
            count = count,
            ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
            time = 30,
        },
    }
end

-- Copies of the vanilla locomotive (entity, item, recipe).
local function copy_locomotive(name, tint, recipe_factor, enabled)
    local e = util.table.deepcopy(data.raw.locomotive["locomotive"])
    e.name = name
    e.minable = { mining_time = 0.5, result = name }
    e.placeable_by = nil
    if tint then
        for _, layer in pairs(e.pictures.rotated.layers) do
            if not layer.draw_as_shadow and not layer.apply_runtime_tint then layer.tint = tint end
        end
    end
    local item = util.table.deepcopy(data.raw["item-with-entity-data"]["locomotive"])
    item.name = name
    item.place_result = name
    item.order = (item.order or "a") .. "-" .. name
    if tint then
        item.icons = { { icon = item.icon or "__base__/graphics/icons/locomotive.png", icon_size = item.icon_size or 64, tint = tint } }
        item.icon = nil
    end
    local recipe = util.table.deepcopy(data.raw.recipe["locomotive"])
    recipe.name = name
    recipe.enabled = enabled
    for _, ing in pairs(recipe.ingredients) do ing.amount = ing.amount * recipe_factor end
    recipe.results = { { type = "item", name = name, amount = 1 } }
    data:extend({ e, item, recipe })
    return e
end

copy_locomotive("hmfea-hs3-train", { 0.75, 0.85, 1.0, 1 }, 2, false)
-- HS3 train icon by ingo (the entity itself only lives a second, tinted vanilla).
for _, proto in pairs({ data.raw["item-with-entity-data"]["hmfea-hs3-train"], data.raw.locomotive["hmfea-hs3-train"] }) do
    proto.icons = nil
    proto.icon = "__hmfea__/graphics/icons/hs3-train.png"
    proto.icon_size = 64
end
local steam = copy_locomotive("hmfea-steam-locomotive", nil, 1, false)
steam.max_speed = data.raw.locomotive["locomotive"].max_speed / 2

-- ingo's Flying Scotsman (A3, no tender): body only, it rides on the vanilla
-- wheels (Justus: "use the game wheels, I want them turning"); the green paint
-- is the colour mask (Justus: "make sure the green part can be recolored").
local STEAM = "__hmfea__/graphics/entity/steam-locomotive/steam-locomotive"
local function steam_layer(suffix, extra)
    local o = { dice = 4, priority = "very-low", allow_low_quality_rotation = true,
        direction_count = 256, scale = 0.5, usage = "train" }
    for k, v in pairs(extra or {}) do o[k] = v end
    return util.sprite_load(STEAM .. suffix, o)
end
steam.pictures = { rotated = { layers = {
    steam_layer(""),
    steam_layer("-mask", { flags = { "mask" }, apply_runtime_tint = true, tint_as_overlay = true }),
    steam_layer("-shadow", { flags = { "shadow" }, draw_as_shadow = true }),
} } }
steam.color = { r = 0.25, g = 0.42, b = 0.18, a = 1 }  -- LNER green
steam.icon = "__hmfea__/graphics/icons/steam-locomotive.png"
steam.icon_size = 64
steam.icons = nil
for _, smoke in pairs(steam.energy_source.smoke or {}) do smoke.position = { 0, -2.22 } end  -- chimney
local steam_item = data.raw["item-with-entity-data"]["hmfea-steam-locomotive"]
steam_item.icon = "__hmfea__/graphics/icons/steam-locomotive.png"
steam_item.icon_size = 64
steam_item.icons = nil

data:extend({
    tech("hmfea-hs2", "railway", 150, "locomotive"),
    tech("hmfea-hs3", "hmfea-hs2", 100, "hmfea-hs3-train"),
})

-- Automatic trains need a locomotive first.
local auto = data.raw.technology["automated-rail-transportation"]
if auto and auto.prerequisites then
    for i, p in pairs(auto.prerequisites) do
        if p == "railway" then auto.prerequisites[i] = "hmfea-hs2" end
    end
end
