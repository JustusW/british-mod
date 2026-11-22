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
        icon = "__base__/graphics/technology/railway.png",
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
local steam = copy_locomotive("hmfea-steam-locomotive", { 0.55, 0.5, 0.45, 1 }, 1, false)
steam.max_speed = data.raw.locomotive["locomotive"].max_speed / 2

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
