-- Vehicle + building reskins. Per design: graphical reskin only — keep
-- vanilla prototype names so saves and other mods stay compatible. Real
-- art lands later; for now, every reskin uses placeholder.
local Placeholder = require("prototypes.placeholder")

local function reskin_item(name, locale_name_key, locale_desc_key, icon)
    local item = data.raw["item"] and data.raw["item"][name]
    if not item then return end
    item.icon = icon or Placeholder.icon_path()
    item.icon_size = 64
    item.icons = nil
    if locale_name_key then
        item.localised_name = { locale_name_key }
    end
    if locale_desc_key then
        item.localised_description = { locale_desc_key }
    end
end

local function reskin_entity(type_, name, locale_name_key, locale_desc_key, icon)
    local entity = data.raw[type_] and data.raw[type_][name]
    if not entity then return end
    entity.icon = icon or Placeholder.icon_path()
    entity.icon_size = 64
    entity.icons = nil
    if locale_name_key then
        entity.localised_name = { locale_name_key }
    end
    if locale_desc_key then
        entity.localised_description = { locale_desc_key }
    end
end

-- Rocket Silo -> EU Headquarters. Art by ingo: drop-in replacements for the
-- vanilla body and front layers (same size and shift); hole, doors, arms,
-- lights and shadow stay vanilla.
local EU_HQ_ICON = "__hmfea__/graphics/icons/eu-hq.png"
reskin_item("rocket-silo",   "hmfea.eu-hq-name",  "hmfea.eu-hq-description", EU_HQ_ICON)
reskin_entity("rocket-silo", "rocket-silo", "hmfea.eu-hq-name", "hmfea.eu-hq-description", EU_HQ_ICON)
local silo = data.raw["rocket-silo"] and data.raw["rocket-silo"]["rocket-silo"]
if silo then
    if silo.base_day_sprite then
        silo.base_day_sprite.filename = "__hmfea__/graphics/entity/eu-hq/eu-hq-body.png"
    end
    if silo.base_front_sprite then
        silo.base_front_sprite.filename = "__hmfea__/graphics/entity/eu-hq/eu-hq-front.png"
    end
end

-- The rocket itself (projectile flying up) -> Union Jack rocket.
reskin_entity("rocket-silo-rocket", "rocket-silo-rocket", "hmfea.union-jack-rocket-name", "hmfea.union-jack-rocket-description")

-- Car -> Mini Cooper
reskin_item("car",   "hmfea.mini-cooper-name", "hmfea.mini-cooper-description")
reskin_entity("car", "car", "hmfea.mini-cooper-name", "hmfea.mini-cooper-description")

-- Tank -> Challenger / Churchill
reskin_item("tank",   "hmfea.tank-name", "hmfea.tank-description")
reskin_entity("car",  "tank", "hmfea.tank-name", "hmfea.tank-description")
