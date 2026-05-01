-- Add hmfea-philosophers-stone as a prerequisite of vanilla tank tech so the
-- player must research the Philosopher's Stone before the Tank.
local tank = data.raw["technology"] and data.raw["technology"]["tank"]
if tank then
    tank.prerequisites = tank.prerequisites or {}
    local already = false
    for _, p in ipairs(tank.prerequisites) do
        if p == "hmfea-philosophers-stone" then
            already = true
            break
        end
    end
    if not already then
        table.insert(tank.prerequisites, "hmfea-philosophers-stone")
    end
end
