-- Top-level dispatcher. Each feature lives in script/<feature>.lua and exports
-- on_* functions; this file wires them into the Factorio event API.
local Medkit = require("script.medkit")
local Pistol = require("script.pistol")
local Exoskeleton = require("script.exoskeleton")

script.on_init(function()
    Medkit.on_init()
    Pistol.on_init()
    Exoskeleton.on_init()
end)

script.on_configuration_changed(function()
    Medkit.on_configuration_changed()
    Pistol.on_configuration_changed()
    Exoskeleton.on_configuration_changed()
end)

script.on_event(defines.events.on_player_used_capsule, function(event)
    Medkit.on_player_used_capsule(event)
end)

script.on_event(defines.events.on_tick, function(event)
    Medkit.on_tick(event)
    Pistol.on_tick(event)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    Exoskeleton.on_player_joined_game(event)
end)

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
    Exoskeleton.on_player_armor_inventory_changed(event)
end)
