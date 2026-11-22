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
require("prototypes.updates.leprechaun")  -- worms as leprechauns (ingo)
require("prototypes.updates.tea-train")  -- locomotives need tea
require("prototypes.updates.hs-trains")  -- HS1/HS2/HS3, after tea-train
require("prototypes.updates.gentleman")
require("prototypes.updates.tank-prereq")
-- Victory jingle replaced (ASSETS A3).
data.raw["utility-sounds"]["default"].game_won = { filename = "__hmfea__/sound/victory.ogg", volume = 1.0 }
require("prototypes.icons").apply_vanilla()  -- last: Baton and Musket icons
