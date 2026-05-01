-- Add hmfea-hand-only to the character's crafting categories so the Cuppa Tea
-- recipe is craftable in the player's hands but not in any assembling-machine.
local character = data.raw["character"] and data.raw["character"]["character"]
if character then
    character.crafting_categories = character.crafting_categories or {}
    local has = false
    for _, cat in ipairs(character.crafting_categories) do
        if cat == "hmfea-hand-only" then has = true; break end
    end
    if not has then
        table.insert(character.crafting_categories, "hmfea-hand-only")
    end
end
