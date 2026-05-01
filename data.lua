-- Placeholder graphics helper must be loaded before any prototype file that
-- might reference it. Keeping it as a require side effect: the module itself
-- exports functions, but loading it early ensures `require("prototypes.placeholder")`
-- from sibling files always returns the same memoised module.
require("prototypes.placeholder")
require("prototypes.items")
require("prototypes.weapons")
require("prototypes.buildings")
require("prototypes.cuppa-tea")
require("prototypes.fish-and-chips")
require("prototypes.cravings")
require("prototypes.recipes")