-- Make hmfea-truthbomb a prerequisite of vanilla rocket-silo so the
-- requirements line "Truthbomb is the final research before the Rocket Silo"
-- holds in the actual tech tree.
local rs = data.raw["technology"] and data.raw["technology"]["rocket-silo"]
if rs then
    rs.prerequisites = rs.prerequisites or {}
    local already = false
    for _, p in ipairs(rs.prerequisites) do
        if p == "hmfea-truthbomb" then
            already = true
            break
        end
    end
    if not already then
        table.insert(rs.prerequisites, "hmfea-truthbomb")
    end
end
