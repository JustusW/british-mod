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
require("prototypes.updates.rambo")  -- after biters: real art replaces the placeholder icons
require("prototypes.updates.gentleman")
require("prototypes.updates.tank-prereq")
require("prototypes.icons").apply_vanilla()  -- last: Baton and Musket icons
