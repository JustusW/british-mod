-- EU Flag entity. Dropped by biters / spitters on death. Mined by hand only
-- — the "not-deconstructable" entity flag stops the deconstruction planner
-- from accepting the flag, which means no order is ever raised and no robot
-- is dispatched. Hand-mining via the regular mine input is unaffected.
-- Five tiered prototypes ship; if the player mines a flag in less than 30
-- seconds, the next-tier (1.5× bigger / slower) flag is re-planted at the
-- same spot.
local Placeholder = require("prototypes.placeholder")

local TIER_COUNT = 5
local BASE_MINING_TIME = 30
local TIME_FACTOR = 1.5
local BASE_SCALE = 0.5
local SCALE_FACTOR = 1.5

local prototypes = {}
for tier = 1, TIER_COUNT do
    local name = (tier == 1) and "hmfea-eu-flag" or ("hmfea-eu-flag-tier-" .. tier)
    local mining_time = BASE_MINING_TIME * TIME_FACTOR ^ (tier - 1)
    local scale = BASE_SCALE * SCALE_FACTOR ^ (tier - 1)
    local proto = {
        type = "simple-entity-with-owner",
        name = name,
        icon = Placeholder.icon_path(),
        icon_size = 64,
        flags = { "placeable-neutral", "player-creation", "not-rotatable", "not-on-map", "not-deconstructable" },
        max_health = 100,
        collision_box = { { -0.3 * scale * 2, -0.3 * scale * 2 }, { 0.3 * scale * 2, 0.3 * scale * 2 } },
        selection_box = { { -0.5 * scale * 2, -0.5 * scale * 2 }, { 0.5 * scale * 2, 0.5 * scale * 2 } },
        minable = {
            mining_time = mining_time,
            results = {},
        },
        picture = {
            filename = "__hmfea__/graphics/placeholder/checkerboard-64.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            scale = scale,
        },
        render_layer = "object",
    }
    -- Tier 1 auto-resolves locale via [entity-name] hmfea-eu-flag;
    -- higher tiers share the same string via cross-reference.
    if tier > 1 then
        proto.localised_name = { "entity-name.hmfea-eu-flag" }
        proto.localised_description = { "entity-description.hmfea-eu-flag" }
    end
    table.insert(prototypes, proto)
end

data:extend(prototypes)
