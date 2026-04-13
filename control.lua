function prepare_storage()
    storage = storage or {}
end

script.on_init(function()
    prepare_storage()
    storage.healing_tick = -1
    
end)

script.on_load(function()
    prepare_storage()
end)

script.on_event("on_player_used_capsule", function(event)
    storage.healing_tick = math.randomm(180, 720)
end)

script.on_tick(function(event)
    
end)