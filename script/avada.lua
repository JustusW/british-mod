-- Avada Kedavra: draws the Tesla turret bolt (hmfea-avada-kedavra-beam) from
-- the caster to the target position when the spell capsule lands. Visual
-- only; the capsule's own area effect deals the damage.
local Log = require("script.log")
local Avada = {}

local BEAM_NAME = "hmfea-avada-kedavra-beam"
local BEAM_TICKS = 20  -- one Tesla bolt flash

function Avada.on_script_trigger_effect(event)
    if event.effect_id ~= "hmfea-avada-kedavra" then return end
    local target = event.target_position
    if not target then return end
    local surface = game.get_surface(event.surface_index)
    if not surface then return end
    local caster = event.source_entity or event.cause_entity
    if not (caster and caster.valid) then return end

    surface.create_entity({
        name = BEAM_NAME,
        position = caster.position,
        source = caster,
        target_position = target,
        duration = BEAM_TICKS,
    })
    Log.debug("avada", string.format(
        "event=bolt x=%.1f y=%.1f",
        target.x, target.y
    ))
end

return Avada
