-- Batons: vanilla grenade mutation. Reskin via locale + placeholder icon, and
-- shrink the area damage to roughly engineer-sized.
local Placeholder = require("prototypes.placeholder")

-- Locale + icon override on the capsule item.
local grenade_item = data.raw["capsule"] and data.raw["capsule"]["grenade"]
if grenade_item then
    grenade_item.icon = Placeholder.icon_path()
    grenade_item.icon_size = 64
    grenade_item.icons = nil
    grenade_item.localised_name = { "hmfea.batons-name" }
    grenade_item.localised_description = { "hmfea.batons-description" }
end

-- Walk the nested action tree on the grenade projectile and shrink any
-- area-radius effects to 1 tile (engineer footprint).
local function shrink_area(node)
    if type(node) ~= "table" then return end
    if node.type == "area" and node.radius then
        node.radius = 1.0
    end
    if node.action then shrink_area(node.action) end
    if node.action_delivery then
        local ad = node.action_delivery
        if ad.target_effects then
            for _, te in pairs(ad.target_effects) do
                shrink_area(te)
            end
        end
    end
    if node.actions then
        for _, sub in pairs(node.actions) do shrink_area(sub) end
    end
end

local grenade_proj = data.raw["projectile"] and data.raw["projectile"]["grenade"]
if grenade_proj and grenade_proj.action then
    shrink_area(grenade_proj.action)
end
