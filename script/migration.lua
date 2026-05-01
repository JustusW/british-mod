-- Save / storage migration framework.
--
-- Pattern:
-- - storage.schema_version :: int — current version of the storage layout.
--   New saves are initialised at LATEST_VERSION in on_init.
-- - on_configuration_changed walks `migrations[v]` for v = current..LATEST-1,
--   each mutating storage and bumping the version by one.
-- - Bump LATEST_VERSION whenever the persisted layout changes
--   incompatibly. Append a function to `migrations` that converts the old
--   layout to the new one.
--
-- Stage 0 is the baseline. There are no migrations yet.
local Log = require("script.log")
local Migration = {}

local LATEST_VERSION = 0

-- migrations[from] mutates `storage` to migrate from version `from` to
-- `from + 1`. The framework bumps storage.schema_version after the function
-- returns. Add new migrations here, never remove.
local migrations = {
    -- [0] = function(storage) ... end,
}

function Migration.on_init()
    storage = storage or {}
    storage.schema_version = LATEST_VERSION
    Log.debug("migration", string.format(
        "event=initialised version=%d",
        LATEST_VERSION
    ))
end

function Migration.on_configuration_changed()
    storage = storage or {}
    if storage.schema_version == nil then
        -- Pre-migration save: treat as version 0.
        storage.schema_version = 0
    end
    while storage.schema_version < LATEST_VERSION do
        local from = storage.schema_version
        local fn = migrations[from]
        if fn then
            Log.debug("migration", string.format(
                "event=running from=%d to=%d",
                from, from + 1
            ))
            fn(storage)
        end
        storage.schema_version = from + 1
    end
end

return Migration
