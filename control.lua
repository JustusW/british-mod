function prepare_storage()
    storage = storage or {}
end

script.on_init(function()
    prepare_storage()
    storage.players = {}
end)

script.on_load(function()
    prepare_storage()
    storage.players = game.players
    for key, value in storage.players do
        storage.players[key].healing_tick = storage.players[key].healing_tick or -1
    end
end)

script.on_event("on_player_joined_game", function(event)
    storage.players.insert(event.player_index)
    for key, value in storage.players do
        storage.players[key].healing_tick = storage.players[key].healing_tick or -1
    end
end)

script.on_event("on_player_left_game", function(event)
    storage.players.remove(event.player_index)
    for key, value in storage.players do
        storage.players[key].healing_tick = storage.players[key].healing_tick or -1
    end
end)


