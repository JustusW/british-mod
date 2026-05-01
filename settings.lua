data:extend({
    {
        type = "bool-setting",
        name = "hmfea-debug-logs",
        setting_type = "runtime-global",
        default_value = false,
        order = "a",
    },
    {
        type = "bool-setting",
        name = "hmfea-debug-fixtures",
        setting_type = "startup",
        default_value = false,
        order = "b",
    },
    {
        type = "bool-setting",
        name = "hmfea-enable-mr-blobby",
        setting_type = "runtime-global",
        default_value = true,
        order = "c",
    },
})
