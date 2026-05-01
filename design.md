# His Majesty's Factory Expansion Act — Design Notes

Implementation choices and engine-level details that the requirements doc deliberately leaves out. Read [requirements.md](requirements.md) first.

> Status: scaffold. Sections are stubbed for the agreed feature list; fill them in as each feature is designed and **before** the corresponding code lands (see the spec-first rule in [DEVELOPMENT.md](DEVELOPMENT.md)).

## Mod identity

- Internal mod name: `hmfea` (info.json `name`). All entity / item / recipe ids are prefixed `hmfea-`.
- Display title: _His Majesty's Factory Expansion Act_.
- Factorio target: 2.0 (no Space Age — `info.json` declares `! space-age`).

## Telemetry

Logs-first approach — when a feature misbehaves we read the log, we don't guess.

- All script-side debug output goes to `script-output/hmfea-debug.txt`. Chat (`game.print`) is reserved for player-facing messages only; debug `game.print` calls are bugs and must be migrated to the log file.
- Every log line is gated on a single runtime-global mod setting `hmfea-debug-logs` (defined in `settings.lua`, default **off**). When the flag is off no I/O happens — log writes are fully short-circuited inside the `debug_log` helper.
- Log format: one line per event, `[<subsystem>] tick=N key=value key=value …`. Keep keys short and stable so `grep` / `findstr` is the primary triage tool.
- Subsystems currently in scope:
  - `[medkit]` — `tick=N event=used player=<idx> delay_ticks=D` on capsule use; `tick=N event=heal_fired healed=<count> amount=A` when the heal fires.
  - Add a new subsystem tag the moment a feature touches `control.lua`. No untagged log lines.
- Per-feature log lines are required: every new feature added under the spec-first flow must list its log line(s) in its design section before the code lands.
- Helper: `debug_log(subsystem, line)` lives at the top of `control.lua` and is the only place log writes happen. Features call it; they never touch `helpers.write_file` directly or hand-roll the gate check.

## Debug fixtures

- Every debug-only entity, recipe, or shortcut item must carry `hmfea-debug-` in its internal name and be gated behind a startup setting `hmfea-debug-fixtures` (default **off**).
- Debug fixtures live under a single subgroup so they're easy to spot in the crafting menu and easy to strip from a release build.
- Tower of London teleport, instant-craft Cuppa Tea, force-craven trigger, etc. are candidate fixtures; add them as features land.

## Forces

- TBD. Default plan: stay on the vanilla `player` and `enemy` forces; biter reskins do not change force assignment.

## Recipes

### Cuppa Tea

- Hand-craft only — recipe is restricted to player crafting (no assembler category).
- Spoils via Factorio 2.0 spoil mechanic (`spoil_ticks`, `spoil_result`). Spoil result triggers a Tower of London event handler (see "Tower of London").
- Ingredient sub-recipes: Teacup (Clay), Pot of Tea, Kettle of Boiling Water — see requirements for the tree. Each sub-component gets its own item / recipe prototype.

### Fish & Chips

- New buildable building: **Greenhouse** — produces raw tea, paper-wood, potatoes, and farmable fish.
- New buildable building: **Woodchipper** — converts wood + potatoes into chips.

## Tower of London

- TBD. Candidate mechanisms: teleport player into a small enclosed structure on a hidden surface, or apply a Factorio "stuck" effect (movement disabled, mining disabled) for 60 seconds. Pick one in design.

## On-Tick debuff (food cravings)

- Per-player state on `storage.players[index]` tracking `stage`, `stage_started_tick`, and `next_prompt_tick`.
- Stage timings: Satiated `3600 × randint(5,10)` ticks, Craving `3600` ticks, Craven infinite.
- Craven enforcement: a hidden invisible beacon attached to each player's force imposing an absurd electricity demand modifier. Beacon is created on entering Craven, destroyed on eating.
- Eating Cuppa Tea or Fish & Chips fires `on_player_consumed_item` (or equivalent) and resets stage to Satiated.

## Vehicles & buildings

- **Rocket silo** — reskinned via prototype `icon` / `picture` overrides on the vanilla rocket silo. No behavior change.
- **Rocket** — graphics-only swap to a Union Jack texture.
- **Car** — graphics-only swap to a Mini Cooper sprite.
- **Tank** — graphics-only swap to Challenger / Churchill sprite. On `on_player_driving_changed_state` for the tank entity, start / stop the looped "God Save the King" sound for that player.

## Equipment

- **Exoskeleton** — `on_player_armor_inventory_changed`: if the player has an exoskeleton equipment in their armor grid, kill the player and print the flavor line.

## Weapons

- **Longbow** — gun prototype with single-shot, manual reload feel. Arrow ammo prototype with `stack_size = 1`.
- **Musket** — gun prototype with very high `cooldown`.
- **Batons** — capsule prototype based on grenade, retextured.
- **Truthbomb (NHS Double Decker Bus)** — research-gated capsule that produces a large explosion. Plays the Michael Caine line on detonation via `on_script_trigger_effect`.

## Medkit (NHS)

**Status: implemented (first cut).**

### Item — `prototypes/items.lua`

- `type = "capsule"`, `name = "medkit"`, `stack_size = 100`, `subgroup = "capsule"`.
- Icon: `__british-mod__/graphics/item_icons/medkit.png`.
- `capsule_action = use-on-self` with `attack_parameters.cooldown = 30` ticks (in-game post-use cooldown), `range = 1`, `ammo_category = "capsule"`, empty `ammo_type`.

### Recipe — `prototypes/recipes.lua`

- `type = "recipe"`, `name = "medkit"`, `enabled = true` (available from game start).
- `energy_required = 1800` (30 minutes at 1× speed), `ingredients = {}` (free).
- Single result: 1 `medkit`.

### Behaviour — `control.lua`

- `prepare_storage()` ensures `storage` exists and seeds `storage.healing_tick = -1` (sentinel: idle / no heal pending). Idempotent.
- `script.on_init` calls `prepare_storage()`.
- `script.on_configuration_changed` calls `prepare_storage()` so a save that pre-dates this mod (or pre-dates the `healing_tick` field) gets the field added without crashing on first medkit use.
- On `on_player_used_capsule` for `medkit`: `storage.healing_tick = math.random(1800, 7200)` ticks → **30–120 seconds** of delay before the heal fires. Using a medkit while a heal is already queued **resets** the timer (single global heal, by design — see requirements.md).
- On `on_tick`: if `storage.healing_tick < 0` the handler returns immediately (no work in the idle case). When the counter is `>= 0` it counts down; when it hits `0` every player in `game.players` with a character is healed for 2000 (`character.damage(-2000, force)`) and the counter is reset to `-1`.
- Telemetry: emits `[medkit] tick=N event=used player=<idx> delay_ticks=<D>` on capsule use and `[medkit] tick=N event=heal_fired healed=<count> amount=2000` when the heal fires, both via the gated `debug_log` helper (see "Telemetry").

## Research

- **Yer'a Wizard 'Arry** → unlocks **Wand** (gun prototype). Spell branch unlocks individual spell capsules (Petrificus Totalus, Abra Kadabra, Avada Kedavra).
- **Philosopher's Stone** — gates Tank recipe.
- **Mr. Blobby** — late-game tech, unlocks a Mr. Blobby capsule / rocket payload. **Runtime-global** setting `hmfea-enable-mr-blobby` (default **on**) toggles availability and the win condition. The **You Whimp** achievement fires from `on_runtime_mod_setting_changed` when this setting flips from `true` → `false` while a game is in progress; the achievement does **not** trigger if the player picks `false` before starting a save (no setting-change event fires in that path). Disabling also removes the win condition for the current run.
- **Truthbomb** — final research before the Rocket Silo prerequisite chain.

## Audio

- Override base `utility-sounds.game_lost` / `game_won` with the _"Fuck this Shit I'm Out"_ clip for the victory replacement.
- Tank sound loop: `on_player_driving_changed_state` starts a per-player `play_sound` loop for the tank.
- Truthbomb voice line: triggered on detonation.

## Biters

- Reskins are pure prototype graphic overrides on `biter`, `spitter`, `biter-spawner`, `spitter-spawner`.
- AI focus: TBD. Candidate is to override `pollution_to_join_attack` / `max_pollution_to_join_attack` and bias attack pathing toward chunks containing oil / resource entities. Needs prototyping.
- **EU Flag** drops: `on_entity_died` filtered to biter / spitter prototypes spawns an `hmfea-eu-flag` entity at the corpse position. The flag is a simple-entity-with-owner with `mining_time = 30` and `not_minable_by_robot = true` (no roboport in vanilla mining flag, but enforce in script if required).

## Save & migration

- TBD. Initial release does not need migrations.

## Non-goals

See [requirements.md](requirements.md#non-goals) for the player-facing list. From an implementation standpoint we additionally do not plan to:

- Replace base sounds globally (only the specific audio events listed above).
- Provide a configurable Tower of London duration in the first cut.
