-- Musket: vanilla submachine-gun mutation. Bump cooldown so it fires
-- "insanely slow"; reskin via locale + placeholder icon.
local Placeholder = require("prototypes.placeholder")

local smg = data.raw["gun"] and data.raw["gun"]["submachine-gun"]
if smg then
    smg.icon = Placeholder.icon_path()
    smg.icon_size = 64
    smg.icons = nil
    smg.localised_name = { "hmfea.musket-name" }
    smg.localised_description = { "hmfea.musket-description" }
    if smg.attack_parameters then
        -- 240 ticks = ~4 seconds between shots; "insanely slow" without
        -- crossing into the 1B sentinel territory the pistol uses.
        smg.attack_parameters.cooldown = 240
    end
end

local smg_item = data.raw["item"] and data.raw["item"]["submachine-gun"]
if smg_item then
    smg_item.icon = Placeholder.icon_path()
    smg_item.icon_size = 64
    smg_item.icons = nil
    smg_item.localised_name = { "hmfea.musket-name" }
    smg_item.localised_description = { "hmfea.musket-description" }
end
