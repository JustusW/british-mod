# His Majesty's Factory Expansion Act — Design Notes

Implementation choices and engine-level details that the requirements doc deliberately leaves out. Read [requirements.md](requirements.md) first.

> Status: scaffold. Sections are stubbed for the agreed feature list; fill them in as each feature is designed and **before** the corresponding code lands (see the spec-first rule in [DEVELOPMENT.md](DEVELOPMENT.md)).
>
> **First step of any feature implementation: explicitly align this file with `requirements.md`.** Read the matching section of `requirements.md`, walk through this file's section for the same feature, and reconcile drift (terminology, defaults, settings names, behaviour) before writing or changing code. Drift accumulates silently otherwise.

## Mod identity

- Internal mod name: `hmfea` (info.json `name`). All entity / item / recipe ids are prefixed `hmfea-`.
- Display title: _His Majesty's Factory Expansion Act_.
- Factorio target: 2.0 base game **without Space Age**. `info.json` declares `! space-age` (the win condition is the British base-game experience, not a Space Age add-on).
- **Spoilage stance**: we use the base-engine spoil mechanism (`spoil_ticks` / `spoil_result` on item prototypes, `spoiling_required: true` in `info.json`) without the Space Age expansion. Spoilage is part of the 2.0 engine; the Space Age expansion just leans on it heavily. Cuppa Tea's Tower of London hook is built on that base mechanism — explicit choice, not an accident.

## Locale

Single source of truth for player-facing strings. Required for every `hmfea-*` prototype before it ships, plus the Pis-what-now? mutation overrides and the runtime flying-text strings.

- File layout: `locale/<lang>/<lang>.cfg`. English is authoritative — `locale/en/en.cfg`. Other languages added as flat translations of the English keys.
- Sections (per Factorio convention) and the keys this mod uses:
  - `[item-name]` — `hmfea-medkit`, `hmfea-longbow`, `hmfea-arrow`, `hmfea-truthbomb`, etc.
  - `[item-description]` — same keys, optional but recommended.
  - `[recipe-name]` / `[recipe-description]` — only for recipes whose name shouldn't fall back to the result item.
  - `[entity-name]` / `[entity-description]` — `hmfea-eu-flag`, future Greenhouse / Woodchipper.
  - `[technology-name]` / `[technology-description]` — `hmfea-truthbomb`, future spell branch, `hmfea-mr-blobby`.
  - `[achievement-name]` / `[achievement-description]` — `hmfea-you-whimp`, `hmfea-bloody-uncivilised`.
  - `[mod-setting-name]` / `[mod-setting-description]` — `hmfea-debug-logs`, `hmfea-debug-fixtures`, future `hmfea-enable-mr-blobby`.
  - `[hmfea]` — mod-internal strings used by `localised_name` / `localised_description` overrides on vanilla prototypes (Pis-what-now?) and by runtime flying-text / `game.print` calls. Example keys: `hmfea.pis-what-now-name`, `hmfea.pis-what-now-description`, `hmfea.pillock-rebuke` (= "You uncivilised pillock."), `hmfea.blobby-consolation` (= "Mr. Blobby says: Did you really win?").
- Runtime strings reach the locale via `{ "hmfea.pillock-rebuke" }` table syntax in `create_local_flying_text`, `game.print`, etc. — never hard-coded English in `control.lua`.
- A new prototype is incomplete until its locale keys exist in `locale/en/en.cfg`. Treat missing locale as a blocker on the same level as a missing icon.

## Placeholder graphics

When a prototype's final art isn't ready, the icon / sprite **must** point at the shared placeholder asset rather than at vanilla art or a missing path. Loud-and-obvious is the point.

- **Asset files** (under `graphics/placeholder/`):
  - `checkerboard-64.png` — 64×64, icon use.
  - `checkerboard-256.png` — 256×256, entity picture / animation use.
- **Pattern**: 8×8-pixel checker (scaled to file resolution) of `#FFFFFF` (white) and `#BF00FF` (bright purple). Distinct from Factorio's own missing-texture magenta/black so "explicitly placeholder" is visually separate from "engine couldn't load this".
- **Reference paths**: `__hmfea__/graphics/placeholder/checkerboard-64.png` for icons; `__hmfea__/graphics/placeholder/checkerboard-256.png` for sprites.
- **Helper**: `prototypes/placeholder.lua` exports a small data-stage helper `Placeholder.icon()` and `Placeholder.picture(size)` returning ready-to-paste sprite definition tables, so prototype authors don't hand-roll paths and we can swap the asset in one place.
- **Release check**: a prototype using the placeholder is implicitly **TBD on art**. Before each release, `grep -ri "graphics/placeholder/" prototypes/` (or the equivalent) should match nothing for implemented features. Treat any placeholder reference as a release-blocking TODO.
- **Subsystem log**: when a placeholder is encountered at runtime by an asset-aware code path (e.g., a feature that snapshots prototype state), it may emit a `[placeholder] tick=N event=in_use prototype=<name>` line via `Log.debug` to surface stragglers.

## Modifying vanilla prototypes

How we change vanilla items, entities, and recipes. Keep this consistent across every feature.

- **Graphical reskin only** (Rocket silo → EU HQ, Tank → Challenger, Car → Mini Cooper, Rocket → Union Jack): mutate the vanilla prototype's graphics fields (`icon`, `icons`, `picture`, `idle_animation`, `corpse`, …) in `data-updates.lua`. **Do not rename the prototype.** The entity name stays `rocket-silo` / `tank` / `car` so vanilla recipes, achievements, save compatibility, and other mods' interop keep working.
- **Behavioural tweaks expressible in prototype data** (Pistol → Pis-what-now? — locale override + cooldown bump; Musket = very slow gun; Batons = small explosion radius): mutate fields on the vanilla prototype in `data-updates.lua` (e.g. `data.raw["gun"]["pistol"].attack_parameters.cooldown = 1_000_000_000`).
- **Behaviour the prototype can't express** (Exoskeleton kills on equip, EU Flag spawning, tank audio loop, food cravings): keep the vanilla prototype intact and add a `script.on_event` handler under `script/<feature>.lua`, required from `control.lua`.
- **Loading order**: define new prototypes in `data.lua`, mutate vanilla prototypes in `data-updates.lua` (base-game data is guaranteed loaded by then). Reserve `data-final-fixes.lua` for reactions to other mods' updates.
- **Adding new items vs replacing vanilla**: prefer new prototypes (`hmfea-…`) for things that are conceptually new (Cuppa Tea, EU Flag, Truthbomb). Reskin vanilla in place for things that are conceptually the same entity wearing a costume (Rocket silo, Tank, Car).

## Telemetry

Logs-first approach — when a feature misbehaves we read the log, we don't guess.

- All script-side debug output goes to `script-output/hmfea-debug.txt`. Chat (`game.print`) is reserved for player-facing messages only; debug `game.print` calls are bugs and must be migrated to the log file.
- Every log line is gated on a single runtime-global mod setting `hmfea-debug-logs` (defined in `settings.lua`, default **off**). When the flag is off no I/O happens — log writes are fully short-circuited inside `Log.debug`.
- Log format: one line per event, `[<subsystem>] tick=N key=value key=value …`. Keep keys short and stable so `grep` / `findstr` is the primary triage tool.
- Subsystems currently in scope:

  | Tag | Status | Log lines |
  |---|---|---|
  | `[medkit]` | **implemented** | `event=used player=<idx> delay_ticks=<D>` on capsule use; `event=heal_fired healed=<count> amount=<HEAL_AMOUNT>` when the heal fires. |
  | `[craving]` | **implemented** | On-Tick debuff stage transitions (`event=stage_change player=<idx> from=<stage> to=<stage>`); `event=achievement_fired name=hmfea-bloody-uncivilised player=<idx>` on Craven entry. |
  | `[mr-blobby]` | **implemented** | Runtime setting flips (`event=setting_changed from=<bool> to=<bool>`); `event=achievement_fired name=hmfea-you-whimp` on first true→false flip; auto-grant marked pending (`event=auto_grant_marked force=<idx>`); auto-grant fired (`event=auto_grant_fired force=<idx>`); victory text branch on launch (`event=win_text variant=<standard\|consolation> force=<idx>`). |
  | `[tower-of-london]` | **implemented** | `event=sentenced player=<idx> ticks=<duration>` on spoiled-tea detection; `event=released player=<idx>` on sentence expiry. |
  | `[exoskeleton]` | **implemented** | `event=killed player=<idx>` on each enforced death. |
  | `[eu-flag]` | **implemented** | Flag spawns (`event=spawned x=<x> y=<y> from=<biter-name>`); blocked robot mining (`event=robot_mining_blocked`). |
  | `[pistol]` | **implemented** | Blocked Pis-what-now? fire attempts (`event=fire_blocked player=<idx>`). |
  | `[expansion]` | **implemented** | Biter expansion-party retargets (`event=retarget group=<idx> from=<x,y> to=<x,y> resource=<name>`). |
  | `[truthbomb]` | **implemented** | `event=detonated x=<x> y=<y>` when the bomb's script trigger fires. |
  | `[tank]` | **implemented** | `event=mounted player=<idx>` / `event=dismounted player=<idx>` on driving-state changes. |
  | `[placeholder]` | **TBD** | Optional surfacing of prototypes still wired to placeholder art (`event=in_use prototype=<name>`). |

  Add a new subsystem row the moment a feature touches `control.lua`. No untagged log lines.
- Per-feature log lines are required: every new feature added under the spec-first flow must list its log line(s) in its design section before the code lands.
- Helper: `Log.debug(subsystem, line)` lives in `script/log.lua` and is the only place log writes happen. `control.lua` and any feature modules `require("script.log")` and call `Log.debug(...)`; they never touch `helpers.write_file` directly or hand-roll the gate check.

## Debug fixtures

- Every debug-only entity, recipe, or shortcut item must carry `hmfea-debug-` in its internal name and be gated behind a startup setting `hmfea-debug-fixtures` (default **off**).
- Debug fixtures live under a single subgroup so they're easy to spot in the crafting menu and easy to strip from a release build.
- Tower of London teleport, instant-craft Cuppa Tea, force-craven trigger, etc. are candidate fixtures; add them as features land.

## Forces

- TBD. Default plan: stay on the vanilla `player` and `enemy` forces; biter reskins do not change force assignment.

## Recipes

### Cuppa Tea

- Hand-craft only — recipe is restricted to player crafting (no assembler category).
- Spoils via the Factorio 2.0 base-engine spoil mechanic. The Cuppa Tea item prototype sets:
  - `spoil_ticks = 60 * 60 * 5` (5 minutes — placeholder, tune in playtesting).
  - `spoil_to_trigger_result = { type = "trigger-effect-item", trigger_effect_item = …, ... }` so the spoil event fires a script trigger we listen for in `control.lua` via `defines.events.on_script_trigger_effect` and route to the Tower of London handler. (`spoil_result` alone would just convert the item; `spoil_to_trigger_result` is what gives us the event hook.)
  - We attribute the trigger to the player who owned the inventory (`event.cause_entity` / `event.source_entity` resolution: walk back to the player whose character holds the inventory the spoil came from). Edge case to nail down in implementation: spoilage in chests / lab inputs vs. a player's pocket — Tower of London only applies to spoils in a player's main / character inventory.
- Ingredient sub-recipes: Teacup (Clay), Pot of Tea, Kettle of Boiling Water — see requirements for the tree. Each sub-component gets its own item / recipe prototype.

### Fish & Chips

- New buildable building: **Greenhouse** — produces raw tea, paper-wood, potatoes, and farmable fish.
- New buildable building: **Woodchipper** — converts wood + potatoes into chips.

## Tower of London

- Trigger: `script/tower-of-london.lua` watches `on_player_main_inventory_changed`. Whenever `hmfea-spoiled-tea` appears in a player's main inventory, the item is removed and the player is sentenced.
- Mechanism: a runtime permission group `hmfea-tower-of-london` is created lazily (every `defines.input_action` set to `false`, with chat-related actions left allowed so the player can still talk through the bars). The player is moved into the group; the original group name is recorded in `storage.tower_of_london.sentenced[player_index].original_group`.
- Duration: 60 seconds (3600 ticks). On `on_tick`, expired sentences are released — the player is moved back to their original group (fallback: `Default`).
- Telemetry: `[tower-of-london]` — see Subsystems table.

## On-Tick debuff (food cravings)

- Per-player state on `storage.players[index]` tracking `stage`, `stage_started_tick`, and `next_prompt_tick`.
- Stage timings: Satiated `3600 × 5 + math.random(0, 3600 * 5)` ticks (5 minutes base + 0–5 minutes random), Craving `3600` ticks, Craven infinite.
- Craven enforcement: when any player on a force enters Craven, every entity on that force whose `type` is `assembling-machine`, `furnace`, `lab`, `rocket-silo`, or `mining-drill` and is currently active is set inactive (factory shutdown). The set of touched entities is stored on `storage.cravings.force_shutdowns[force_index]`. When the last Craven player on the force is satisfied, the same set is restored to active.
- Eating Cuppa Tea or Fish & Chips fires `on_player_consumed_item` (or equivalent) and resets stage to Satiated.

## Vehicles & buildings

- **Rocket silo** — reskinned via prototype `icon` / `picture` overrides on the vanilla rocket silo. No behavior change.
- **Rocket** — graphics-only swap to a Union Jack texture.
- **Car** — graphics-only swap to a Mini Cooper sprite.
- **Tank** — graphics-only swap to Challenger / Churchill sprite. On `on_player_driving_changed_state` for the tank entity, start / stop the looped "God Save the King" sound for that player.

## Equipment

- **Exoskeleton** — death triggers from a single helper `enforce_no_exoskeleton(player)` that scans the armor grid and, if any exoskeleton equipment is present, kills the player and prints the flavor line. The helper is called from:
  - `on_player_armor_inventory_changed` — catches live equips.
  - `on_player_joined_game` — catches save loads where the equipment was already in the grid (the inventory-changed event does not fire on load).
  - `on_init` and `on_configuration_changed` — iterate `game.connected_players` and apply the helper, so adding the mod to an existing save retroactively enforces the rule.

## Weapons

Listed in tech-unlock order, matched to `requirements.md`. Mix of new `hmfea-` prototypes and vanilla mutations — see the **Modifying vanilla prototypes** rule for the pattern.

### Tier 0 — available from game start

- **Longbow** — **new** prototype `hmfea-longbow` (gun) with a single-shot / manual-reload attack profile. New ammo prototype `hmfea-arrow` with `stack_size = 1`. Recipes `hmfea-longbow` (10 wood) and `hmfea-arrow` (1 wood + 1 stone → 1 arrow), both `enabled = true` so they're craftable from the first tick — no tech gate.
- **Pis-what-now?** — **mutation of vanilla `pistol`** in `data-updates.lua`. Two layers:
  - **Locale**: override `localised_name` and `localised_description` (British-mocking voice).
  - **No-fire enforcement**: bump `attack_parameters.cooldown` on the pistol prototype to `1_000_000_000` ticks so the gun never recharges (well below the int32 ceiling — leaves headroom for prototype-stage validation in any tooling). Belt-and-braces, a runtime guard runs each tick: scan `game.connected_players` whose `character.shooting_state.state ~= defines.shooting.not_shooting` and whose currently selected gun is `pistol`. For each match, emit the flying-text _"You uncivilised pillock."_ (locale key `hmfea.pillock-rebuke`) at the player's position via `player.create_local_flying_text` (or `surface.create_entity{ type = "flying-text" }`), reassign the whole `character.shooting_state` table — `character.shooting_state = { state = defines.shooting.not_shooting, position = current.position }` (Factorio requires whole-table assignment; field-level writes don't propagate) — and throttle the message to once per ~60 ticks per player to avoid spam. Telemetry: `[pistol] tick=N event=fire_blocked player=<idx>`. Vanilla pistol recipe and its tech are kept untouched so the player can craft it alongside the Longbow.

### Tier 1 — Military 1 research

- **Batons** — **mutation of vanilla `grenade`** in `data-updates.lua`. Reskin (icon, throw animation), keep capsule throw mechanics, keep **Military 1** as the gate (vanilla tech id `military`). **Shrink the explosion**: rewrite `capsule_action.attack_parameters.action` so the area-effect radius is reduced to roughly one engineer footprint (~1 tile) — only an entity standing on the impact tile takes damage. Adjust the explosion graphic prototype's `animation` scale to match so the visual doesn't lie about the lethal radius.

### Tier 2 — Military 2 research

- **Musket** — **mutation of vanilla `submachine-gun`** in `data-updates.lua`. Reskin and bump `attack_parameters.cooldown` very high. Keep the **Military 2** technology as the gate.

### Tier 3 — Truthbomb research (final tech before Rocket Silo)

- **Truthbomb (NHS Double Decker Bus)** — **new** prototype `hmfea-truthbomb` (capsule). New research `hmfea-truthbomb` is added to the tech tree as the prerequisite of `rocket-silo`. Detonation produces a large explosion via `on_script_trigger_effect` and plays the Michael Caine line.

Vanilla recipes / techs that the mutations target are kept enabled — these are reskins / retunes, not deletions. No `disable-recipe` or hidden-tech surgery is required.

## Medkit (NHS)

### Item — `prototypes/items.lua`

- `type = "capsule"`, `name = "hmfea-medkit"`, `stack_size = 100`, `subgroup = "capsule"`.
- Icon: `__hmfea__/graphics/item_icons/medkit.png`.
- Locale: `[item-name] hmfea-medkit` and `[item-description] hmfea-medkit` in `locale/en/en.cfg`.
- `capsule_action = use-on-self` with `attack_parameters.cooldown = 30` ticks (in-game post-use cooldown), `range = 1`, `ammo_category = "capsule"`, empty `ammo_type`.

### Recipe — `prototypes/recipes.lua`

- `type = "recipe"`, `name = "hmfea-medkit"`, `enabled = true` (available from game start).
- `energy_required = 1800` (30 minutes at 1× speed), `ingredients = {}` (free).
- Single result: 1 `hmfea-medkit`.

### Behaviour — `control.lua`

- `prepare_storage()` ensures `storage` exists and seeds `storage.healing_tick = -1` (sentinel: idle / no heal pending). Idempotent.
- `script.on_init` calls `prepare_storage()`.
- `script.on_configuration_changed` calls `prepare_storage()` so a save that pre-dates this mod (or pre-dates the `healing_tick` field) gets the field added without crashing on first medkit use.
- On `on_player_used_capsule` for `hmfea-medkit`: `storage.healing_tick = math.random(1800, 7200)` ticks → **30–120 seconds** of delay before the heal fires. Using a medkit while a heal is already queued **resets** the timer (single global heal, by design — see requirements.md).
- On `on_tick`: if `storage.healing_tick < 0` the handler returns immediately (no work in the idle case). When the counter is `>= 0` it counts down; when it hits `0` every player in `game.players` with a character is healed by `HEAL_AMOUNT` (`character.damage(-HEAL_AMOUNT, force)`) and the counter is reset to `-1`.
- Heal magnitude: `HEAL_AMOUNT = 2000` is a top-of-file constant in `control.lua` (above `prepare_storage`). Vanilla character max HP is 250, so any large negative value caps to full health on any reasonable build — treat 2000 as a sentinel meaning "full heal", not a literal HP number.
- Telemetry: emits `[medkit] tick=N event=used player=<idx> delay_ticks=<D>` on capsule use and `[medkit] tick=N event=heal_fired healed=<count> amount=<HEAL_AMOUNT>` when the heal fires, both via `Log.debug` (see "Telemetry").

## Research

- **Yer'a Wizard 'Arry** → unlocks **Wand** (gun prototype). Spell branch unlocks individual spell capsules (Petrificus Totalus, Abra Kadabra, Avada Kedavra).
- **Philosopher's Stone** — gates Tank recipe.
- **Mr. Blobby** — late-game tech, unlocks a Mr. Blobby capsule / rocket payload. **Runtime-global** setting `hmfea-enable-mr-blobby` (default **on**) toggles whether the tech must be researched normally or is auto-granted on prerequisite completion — see "Win condition". The **You Whimp** achievement fires from `on_runtime_mod_setting_changed` when this setting flips from `true` → `false` while a game is in progress; the achievement does **not** trigger if the player picks `false` before starting a save (no setting-change event fires in that path). Setting prototype must be added to `settings.lua` when implemented.
- **Truthbomb** — final research before the Rocket Silo prerequisite chain.

## Win condition

The win path is always the same: launch a Mr. Blobby payload via the rocket silo. Victory triggers on `on_rocket_launched` carrying the Blobby payload. The runtime setting `hmfea-enable-mr-blobby` controls **how the player gets the Mr. Blobby technology**, not the win path itself.

- **Setting on (default)**: the Mr. Blobby tech is researched normally — vanilla research mechanics, no script involvement.
- **Setting off** (chosen at game start or flipped during the run): the Mr. Blobby research is **auto-granted** the moment its prerequisites are fulfilled. Implementation:
  - Hook `on_runtime_mod_setting_changed` on `hmfea-enable-mr-blobby`. When the new value is `false`, check each force's `technologies["hmfea-mr-blobby"].prerequisites_satisfied`. If satisfied, set `technologies["hmfea-mr-blobby"].researched = true`. If not yet satisfied, mark `storage.blobby_pending_auto_grant[force_index] = true` and watch `on_research_finished` to grant the moment the last prereq lands.
  - On `on_init` and `on_configuration_changed`, run the same satisfaction check for every force using the current setting value (covers fresh saves with the setting already off and mod-update cases).
- **Sticky**: once the auto-grant has fired, `storage.blobby_auto_granted[force_index] = true`. Set on the same tick as the `researched = true` flip. The grant cannot be reverted; Factorio has no clean "un-research" path and we deliberately do not provide one. Re-enabling the setting later just stops *future* prereq completions from auto-granting (irrelevant after the fact, since the tech is already researched).
- **Victory text + state**: on `on_rocket_launched` with the Blobby payload, if `storage.blobby_auto_granted[force_index]` is true the rendered text is the consolation `{ "hmfea.blobby-consolation" }` (= "Mr. Blobby says: Did you really win?"); otherwise the standard victory text fires. The handler then calls `game.set_game_state{ game_finished = true, player_won = true, victorious_force = force, can_continue = true }` to confirm victory.
- **Vanilla-victory suppression**: when a rocket launches **without** the Blobby payload, the handler calls `game.set_game_state{ game_finished = false, player_won = false, can_continue = true }` to undo any vanilla victory state and prints `hmfea.win-suppressed` to the force. This makes Mr. Blobby the only acknowledged win condition.
- **Audio is unchanged in both cases** — the victory jingle replacement applies to either path.
- Telemetry: see the `[mr-blobby]` row in the Telemetry table for the events emitted.

The **You Whimp** achievement is wired separately (see Achievements). Trigger is the first `true → false` flip of `hmfea-enable-mr-blobby` during a running game; it does not fire on a fresh-start setting choice and does not depend on the auto-grant having fired yet.

## Audio

- Override base `utility-sounds.game_won` with the _"Fuck this Shit I'm Out"_ clip for the victory replacement. `game_lost` is left untouched.
- Tank sound loop: `on_player_driving_changed_state` starts a per-player `play_sound` loop for the tank.
- Truthbomb voice line: triggered on detonation.

## Biters

- Reskins are pure prototype graphic overrides on `biter`, `spitter`, `biter-spawner`, `spitter-spawner`.
- **Expansion-party AI focus** (implemented in `script/expansion.lua`): the bias only applies to expansion / colonisation groups — the AI parties dispatched by Factorio's enemy-expansion logic to found new nests — not to ordinary attack groups.
  - Hook: `defines.events.on_unit_group_finished_gathering`. For groups whose `command.type == defines.command.build_base`, retarget the destination to the nearest `crude-oil` resource entity within 256 tiles, falling back to the nearest resource of any type if no oil is reachable. Untouched groups (attack-by-pollution) keep vanilla behaviour.
  - Map settings (`enemy_expansion.*`) are not tuned; the bias is purely script-side.
  - Telemetry: `[expansion]` subsystem — see Subsystems table.
- **EU Flag** drops: `on_entity_died` filtered to biter / spitter prototypes spawns an `hmfea-eu-flag` (tier 1) at the corpse position. The flag is a `simple-entity-with-owner` with `minable.mining_time = 30` seconds.
- **Tiered escalation prototypes**: five tiered flag prototypes ship: `hmfea-eu-flag` (tier 1), `hmfea-eu-flag-tier-2` … `hmfea-eu-flag-tier-5`. Each tier has `mining_time = 30 × 1.5^(tier-1)` and `picture.scale = 0.5 × 1.5^(tier-1)` so the escalated flag is both bigger and slower to mine.
- **Mining-state polling**: per-tick, `script/eu-flag.lua` reads each connected player's `LuaPlayer.mining_state.mining` + `LuaPlayer.selected`. When a player begins mining a flag, the `(player_index → unit_number, start_tick)` pair is recorded in `storage.eu_flag.mining_starts`. When mining is interrupted (state goes false or selection changes), the entry is cleared.
- **Respawn on fast mining**: `on_pre_player_mined_item` filtered on flag entities. If the elapsed mining ticks (`game.tick - start_tick`) is `< 30 × 60`, queue a deferred (next tick) respawn at the same position using the next tier's prototype, capped at tier 5. Position is captured before the entity is removed.
- **Robot-mining block**: `simple-entity-with-owner` has no native "not minable by robot" flag, so robot mining is blocked via `on_marked_for_deconstruction` filtered on the flag prototype: cancel the deconstruction order (`entity.cancel_deconstruction(force)`) and surface a `hmfea.eu-flag-no-bots` flying-text.

## Achievements

Single source of truth for every achievement the mod ships. New achievements get added here **before** their prototype lands in `prototypes/achievements.lua` (the per-type prototype file, required from `data.lua`) and **before** the firing code lands in `control.lua`.

| Internal name | Display title | Status | Trigger | Subsystem log tag |
|---|---|---|---|---|
| `hmfea-you-whimp` | You Whimp | **implemented** | `on_runtime_mod_setting_changed` for `hmfea-enable-mr-blobby` flipping `true → false` during a running game. Does **not** fire on a fresh-start setting choice. | `[mr-blobby]` |
| `hmfea-bloody-uncivilised` | Bloody Uncivilised | **implemented** | Player enters the **Craven** stage of the On-Tick debuff (see "On-Tick debuff"). | `[craving]` |

Locale ids follow the prototype name (`achievement-name.hmfea-you-whimp`, etc.).

## Settings

Single source of truth for every mod setting. Match this against `settings.lua` on every alignment pass.

| Internal name | Type | Default | Status | Purpose |
|---|---|---|---|---|
| `hmfea-debug-logs` | runtime-global bool | `false` | **implemented** | Gates all `Log.debug` writes (see "Telemetry"). |
| `hmfea-debug-fixtures` | startup bool | `false` | **implemented** | Gates debug-only entities, recipes, shortcuts (see "Debug fixtures"). |
| `hmfea-enable-mr-blobby` | runtime-global bool | `true` | **implemented** | Toggles Mr. Blobby tech, win condition, and the **You Whimp** achievement trigger (see "Research"). |

## Save & migration

Storage layout is versioned via `storage.schema_version`. The framework lives in `script/migration.lua` and follows this contract:

- `Migration.on_init()` runs from `control.lua`'s `script.on_init` **before** any other module's `on_init`. It sets `storage.schema_version = LATEST_VERSION` (currently `0`).
- `Migration.on_configuration_changed()` runs from `control.lua`'s `script.on_configuration_changed` **before** any other module's `on_configuration_changed`. It walks `migrations[from]` for `from = current..LATEST-1`, each mutating storage and bumping the version by one.
- New migrations append to the `migrations` table in `script/migration.lua`. Never remove an entry. Bump `LATEST_VERSION` whenever the persisted layout changes incompatibly.

Current version: `0` (baseline). No migrations registered yet.

When a feature module changes its storage shape, the change goes through this framework so saves persisted under older mod versions get upgraded silently on load.

## Non-goals

See [requirements.md](requirements.md#non-goals) for the player-facing list. From an implementation standpoint we additionally do not plan to:

- Replace base sounds globally (only the specific audio events listed above).
- Provide a configurable Tower of London duration in the first cut.
