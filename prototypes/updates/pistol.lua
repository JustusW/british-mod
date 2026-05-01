-- Pis-what-now?: rename + cripple the vanilla pistol.
--
-- - Locale: name and description point at hmfea-mocking strings.
-- - Cooldown: bumped to 1_000_000_000 ticks so the gun never recharges.
--   The runtime guard in script/pistol.lua intercepts shoot attempts and
--   flashes the "You uncivilised pillock." flying-text at the player.
local pistol = data.raw["gun"] and data.raw["gun"]["pistol"]
if pistol then
    pistol.localised_name = { "hmfea.pis-what-now-name" }
    pistol.localised_description = { "hmfea.pis-what-now-description" }
    if pistol.attack_parameters then
        pistol.attack_parameters.cooldown = 1000000000
    end
end

-- The pistol item itself takes the same display name so the inventory tooltip
-- matches the gun prototype.
local pistol_item = data.raw["item"] and data.raw["item"]["pistol"]
if pistol_item then
    pistol_item.localised_name = { "hmfea.pis-what-now-name" }
    pistol_item.localised_description = { "hmfea.pis-what-now-description" }
end
