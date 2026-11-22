-- Trains run on tea (script/tea-train.lua does the drinking and the strike).
-- The locomotive keeps its normal fuel. Its tea slot is the burner's spent
-- fuel slot (burnt result inventory, 1 slot): players can take things out of
-- it but not put things in, so the script moves a Cuppa Tea there from the
-- fuel slots. For that, tea needs a fuel category the locomotive accepts.
data:extend({
    { type = "fuel-category", name = "hmfea-tea" },
})

local tea = data.raw.capsule["hmfea-cuppa-tea"]
if tea then
    tea.fuel_categories = { "hmfea-tea" }  -- 2.1: a list
    tea.fuel_value = "1kJ"  -- only so it fits a fuel slot; worthless as fuel
end

local loco = data.raw.locomotive["locomotive"]
if loco and loco.energy_source and loco.energy_source.type == "burner" then
    local src = loco.energy_source
    src.fuel_categories = src.fuel_categories or { "chemical" }
    table.insert(src.fuel_categories, "hmfea-tea")
    src.burnt_inventory_size = 1  -- the tea slot
end
