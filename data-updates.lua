-- Vanilla-prototype mutations live here. Per design.md "Modifying vanilla
-- prototypes": data-updates.lua runs after every mod's data.lua so vanilla
-- prototypes are guaranteed loaded.

require("prototypes.updates.pistol")
require("prototypes.updates.character")
require("prototypes.updates.batons")
require("prototypes.updates.musket")
require("prototypes.updates.rocket-silo-prereqs")
require("prototypes.updates.vehicles")
require("prototypes.updates.biters")
