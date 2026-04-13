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
    if event.item.name == "medkit" then
        game.print(event.item.name)
        storage.healing_tick = math.random(1800, 7200)
        game.print(storage.healing_tick)
    end
    
end)

script.on_event("on_tick", function(event)
    if storage.healing_tick >= -1 then
        game.print(storage.healing_tick)
        if storage.healing_tick == 0 then
            for key, value in pairs(game.players) do
                value.character.damage(-2000, value.force.name)        
            end
        end
        storage.healing_tick = storage.healing_tick -1
    end
end)