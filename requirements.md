# His Majesty's Factory Expansion Act — Requirements

The factory has been issued a Royal Charter. Tea is mandatory, exoskeletons are forbidden, and victory is announced by Michael Caine.

## Player flow

1. Standard Factorio start.
2. The colony is on a craving timer from the first tick: every player carries an On-Tick debuff that escalates from **Satiated** to **Craving** to **Craven** unless food rules are observed (see "Food cravings").
3. Hand-craft a **Cuppa Tea** or build the supply chain for **Fish & Chips** to keep the timer reset. Tea spoils — let it spoil and you go to the Tower of London.
4. Research climbs a re-themed tree: weapons unlock in order Longbow & Pis-what-now? at start (only the Longbow actually fires) → Batons (Military 1) → Musket (Military 2) → Truthbomb (see "Weapons"), an NHS medkit is added (see "Medkit (NHS)"), and key milestones gate behind absurd British memes (Wand → Spells, Philosopher's Stone, Truthbomb, Mr. Blobby).
5. Vehicles arrive as iconic British machines: Mini Cooper, Challenger/Churchill, and the rocket silo as the EU Headquarters.
6. Win by firing **Mr. Blobby** into space. Disabling Mr. Blobby mid-game via the runtime mod setting earns the **You Whimp** achievement and makes the Mr. Blobby research auto-grant the moment its prerequisites are fulfilled — once granted there is no way to revert it. The victory screen reads _"Mr. Blobby says: Did you really win?"_ in place of the usual jingle text whenever the auto-grant has fired during the run.

## Rules

- **Officers don't run.** Equipping an exoskeleton kills the player instantly.
- **Tea is fragile.** Cuppa Tea is hand-craft only; if it spoils on you, you serve a 60-second sentence in the Tower of London (player locked out / teleported / immobilised — exact mechanism in design).
- **Food keeps you civilised.** The On-Tick debuff cannot be paused or disabled in-game. If the Craven stage triggers, every assembling machine, furnace, lab, rocket silo, and mining drill on the player's force is paused until somebody on the force eats.
- **No bots on EU soil.** EU Flags dropped by dead biters cannot be mined by construction bots — only by hand, and hand-mining one takes 30 seconds.
- **Tank protocol.** While occupying the tank, "God Save the King" plays continuously. It cannot be muted without muting the game itself. The recording is intentionally low quality (drunk man yelling, or similar).

## Recipes

### Cuppa Tea

Hand-craftable only. Cannot be assembler-produced. Spoils — and a spoiled Cuppa Tea triggers the **Tower of London** sentence.

Ingredient tree:

- **Teacup (Clay)** — built from clay, which is smelted/produced from stone.
- **Pot of Tea** — combines a **Pot (Porcelain)** with **Tea Leaves**:
  - Porcelain is made from clay + coal.
  - Tea Leaves are made from **paper** (wood from the greenhouse) + **raw tea** (grown in the greenhouse).
- **Kettle of Boiling Water** — a **Kettle** (metal + copper) filled from a barrel of water and smelted in a furnace.

### Fish & Chips

A buildable food chain — the alternative to Cuppa Tea when the Satiated timer asks for it.

- **Fish** — hand-caught from water tiles, or grown in the greenhouse.
- **Chips** — produced in the **Woodchipper** (a new building) from wood and potatoes; potatoes are grown in the greenhouse.

## Vehicles & buildings

- **Rocket silo** is reskinned as the **EU Headquarters**. It still launches rockets — see Mr. Blobby for the win condition.
- **Rocket** is a giant Union Jack.
- **Car** is a Mini Cooper.
- **Tank** is a Challenger / Churchill / equivalent. Mounting it loops "God Save the King" (deliberately bad recording).

## Equipment

- **Exoskeleton** is fatal on equip. Flavor: _"British Officers don't run."_ The death is immediate and intentional.

## Weapons

Listed in tech-unlock order. Each entry says whether it's a new weapon or a mutation of a specific vanilla item.

### Tier 0 — available from game start

- **Longbow** — **new** weapon, the proper first armament. Crafted from 10 wood. Arrows: 1 wood + 1 stone → 1 arrow. Arrows do not stack (max stack 1). Coexists with Pis-what-now? — both are craftable from the first tick.
- **"Pis-what-now?"** — the vanilla **Pistol**, kept in the game, renamed and reflavored in mockingly British fashion (the description questions what this curious little sidearm is doing on a proper battlefield). **It cannot be fired.** Attempting to shoot it produces a flying-text message at the player's position: _"You uncivilised pillock."_ The gun is otherwise carried and equipped normally — the British contempt is conveyed by refusing to dignify the shot.

### Tier 1 — Military 1 research

- **Batons** — replace the vanilla **Grenade**. Thrown like grenades, roughly cricket-bat physics. Explosion radius covers only a single unit the size of the engineer. 

### Tier 2 — Military 2 research

- **Musket** — replaces the vanilla **Submachine Gun**. Insanely slow rate of fire.

### Tier 3 — Truthbomb research (final tech before Rocket Silo)

- **Truthbomb (NHS Double Decker Bus)** — **new** weapon, not a vanilla replacement. Deploys as a massive explosion, accompanied by Michael Caine: _"You were only supposed to blow the bloody doors off."_

## Medkit (NHS)

- Free to craft.
- 30-minute craft time — long enough to demand factory planning.
- 30–120 second activation delay between use and effect (randomised per use).
- On activation, fully heals **every player on the map** — the NHS treats the whole nation, not just the patient.
- Single global heal timer: only one outstanding heal exists at a time. Using a medkit while one is already queued **resets** the timer rather than enqueueing a second one.

## Research

The visible tech tree leans into British memes, gating absurd capabilities behind expensive prerequisites.

- **Yer'a Wizard 'Arry** — unlocks the **Wand**, which in turn enables a research branch of spells:
  - **Petrificus Totalus** — permanently disables movement of the target. If the target is a player, they keep their character but cannot move, hand-mine, or hand-craft for the rest of the run. They can still play from radar — open the map, place ghosts, set up blueprints — and let construction bots do the work. Hope they have robots.
  - **Abra Kadabra** — nuclear explosion centred on the player.
  - **Avada Kedavra** — fires a Tesla turret bolt.
- **Philosopher's Stone** — required prerequisite to unlock the **Tank**.
- **Mr. Blobby** — extremely expensive, late-game tech. The win path is always the same: fire Mr. Blobby into space via the rocket silo. What changes is **how you get the tech**. Toggled by a **runtime mod setting** (changeable during a running game), with prominent warnings on flip:
  - **On (default)**: the tech must be researched normally.
  - **Off** (at game start or flipped on mid-run): the Mr. Blobby research is **auto-granted** the moment its prerequisites are fulfilled (or immediately if they already are). Once auto-granted the research cannot be reverted — re-enabling the setting later does not undo the grant. Once Mr. Blobby has spoken, he has spoken.
  - **You Whimp** achievement: granted only when the setting is **flipped off during a running game**. Picking the setting before starting a fresh save does not qualify.
  - **Victory message**: whenever the auto-grant has fired during the run, the victory text is _"Mr. Blobby says: Did you really win?"_ instead of the standard victory line. Audio is unchanged.
- **Truthbomb (NHS Double Decker Bus)** — final pre-rocket research. See Weapons.

## Food cravings (On-Tick debuff)

Every player runs a three-stage debuff cycle from the first tick. Eating Cuppa Tea or Fish & Chips resets the cycle to Satiated.

- **Satiated** — duration **5 minutes base + a random 0–5 minutes on top** (so total 5–10 minutes, randomised per cycle). Ends with a forced random prompt: _Fish & Chips or Cuppa Tea?_
- **Craving** — duration `3600 ticks` (one minute). Final warning window.
- **Craven** — infinite. The factory is effectively disabled: every assembling machine, furnace, lab, rocket silo, and mining drill on the player's force is paused until somebody on the force eats. Originally drafted as a fake-beacon electricity drain; the implementation flips the entities' active state directly because it is reliable regardless of network coverage.

Reaching Craven grants the **Bloody Uncivilised** achievement.

## Visuals

- **Placeholder graphics.** Any item, entity, recipe, or technology whose final art isn't ready ships with a clearly-marked placeholder — a **checkerboard of white and bright purple**. The placeholder is loud on purpose so missing art is obvious in playtesting and never quietly slips through to a release.

## Audio

- Victory jingle replaced with _"Fuck this Shit I'm Out."_
- Tank loop: continuous "God Save the King" (bad recording — drunk yelling or similar).
- Truthbomb detonation: Michael Caine voice line.
- **Placeholder audio.** Any final clip that isn't ready ships with a placeholder — usually a short vanilla sound effect, or silence in the case of voice lines. Like the placeholder graphics rule, an audio placeholder is a marker that the asset is **TBD** and must be replaced before release. Design lists which clips are still placeholders.

## Biters

- Biters are reskinned as **Rambo** soldiers — GI helmets, medals.
- **Spitter nests** are reskinned as **Barrack Tents**.
- **Biter nests** are reskinned as **EU Buildings**.
- Biter **expansion parties** prioritise **oil patches** first and other resource patches second when picking where to found a new nest. The party retargets to the **nearest** crude-oil entity (within reach of the gathering position), falling back to the nearest resource of any type. The intent is to block resources effectively — settling on top of patches denies them to the player. (Regular attack groups are unaffected — only the expansion / colonisation pathfinding leans toward resources.)
- Dead biters drop an **EU Flag** on the ground:
  - Mining an EU Flag takes 30 seconds at base mining speed.
  - Bots cannot mine EU Flags — hand-mining only.
  - **Escalating respawn**: if the player completes mining a flag in **less than 30 seconds** (i.e. with mining-speed upgrades), the flag is replanted at the same spot **50% bigger** and the next mining must take precisely 30 seconds at that scale. The escalation continues each time the player out-paces the 30-second floor (capped after a few tiers).

## Non-goals

- **No bot-friendly EU Flag mining.** The 30-second hand-mining cost is the point.
- **No skipping cravings.** The On-Tick debuff cannot be turned off in-game.

## Open / suggested features (not yet agreed)

These are bullets from the source doc that have not been signed off; they live here as a parking lot until agreed or rejected.

- _Insert your feature here_
- Beans
- Bacon & Egg

---

Implementation choices, internal entity names, and engine-level details live in [design.md](design.md).
