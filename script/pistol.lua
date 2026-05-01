-- "Pis-what-now?" — the vanilla pistol kept in the game but unable to fire.
-- Cooldown bump in data-updates.lua does the heavy lifting; this module is the
-- belt-and-braces runtime guard: any per-tick attempt to shoot the pistol is
-- intercepted, the player is reminded of their station, and the shooting
-- state is reset.
local Log = require("script.log")
local Pistol = {}

local THROTTLE_TICKS = 60  -- rate-limit the rebuke message per player

local function init_storage()
    storage = storage or {}
    storage.pistol = storage.pistol or {}
    storage.pistol.last_message = storage.pistol.last_message or {}
end

function Pistol.on_init()
    init_storage()
end

function Pistol.on_configuration_changed()
    init_storage()
end

function Pistol.on_tick(event)
    if not storage.pistol then init_storage() end
    local last = storage.pistol.last_message
    local tick = event.tick

    for _, player in pairs(game.connected_players) do
        local character = player.character
        if character then
            local shooting_state = character.shooting_state
            if shooting_state and shooting_state.state ~= defines.shooting.not_shooting then
                local guns_inventory = character.get_inventory(defines.inventory.character_guns)
                local selected_gun_index = character.selected_gun_index
                if guns_inventory and selected_gun_index then
                    local gun_stack = guns_inventory[selected_gun_index]
                    if gun_stack and gun_stack.valid_for_read and gun_stack.name == "pistol" then
                        local prev = last[player.index] or -math.huge
                        if tick - prev >= THROTTLE_TICKS then
                            player.create_local_flying_text({
                                text = { "hmfea.pillock-rebuke" },
                                position = player.position,
                            })
                            last[player.index] = tick
                            Log.debug("pistol", string.format(
                                "event=fire_blocked player=%d",
                                player.index
                            ))
                        end
                        -- Whole-table reassignment: Factorio requires it for
                        -- shooting_state; field-level writes don't propagate.
                        character.shooting_state = {
                            state = defines.shooting.not_shooting,
                            position = shooting_state.position,
                        }
                    end
                end
            end
        end
    end
end

return Pistol
