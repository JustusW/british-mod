# His Majesty's Factory Expansion Act — Requirements

The factory has been issued a Royal Charter. Tea is mandatory, exoskeletons are forbidden, and victory is announced by Michael Caine.

## Player flow

1. Standard Factorio start.
2. The colony is on a craving timer from the first tick: every player carries an "On Tick" debuff that escalates from **Satiated** to **Craving** to **Craven** unless food rules are observed (see "Food cravings").
3. Hand-craft a **Cuppa Tea** or build the supply chain for **Fish & Chips** to keep the timer reset. Tea spoils — let it spoil and you go to the Tower of London.
4. Research climbs a re-themed tree: vanilla weapons are replaced by Longbow / Musket / Batons, the medkit becomes the NHS, and key milestones gate behind absurd British memes (Wand → Spells, Philosopher's Stone, Mr. Blobby, the Truthbomb).
5. Vehicles arrive as iconic British machines: Mini Cooper, Challenger/Churchill, and the rocket silo as the EU Headquarters.
6. Win by firing **Mr. Blobby** into space (when enabled). Disable Mr. Blobby mid-game via the runtime mod setting to receive the **You Whimp** achievement and skip the win condition for that run.

## Rules

- **Officers don't run.** Equipping an exoskeleton kills the player instantly.
- **Tea is fragile.** Cuppa Tea is hand-craft only; if it spoils on you, you serve a 60-second sentence in the Tower of London (player locked out / teleported / immobilised — exact mechanism in design).
- **Food keeps you civilised.** The On-Tick debuff cannot be paused or disabled in-game. If the Craven stage triggers, your factory is effectively shut down (a fake beacon imposes a near-infinite electricity demand) until you eat.
- **No bots on EU soil.** EU Flags dropped by dead biters cannot be mined by construction bots — only by hand, and hand-mining one takes 30 seconds.
- **Tank protocol.** While occupying the tank, "God Save the King" plays continuously and cannot be muted in-mod. The recording is intentionally low quality (drunk man yelling, or similar).

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

- **Longbow** — crafted from 10 wood. Each arrow is 1 wood + 1 stone → 1 arrow. Arrows do not stack (max stack 1).
- **Musket** — gated behind research; insanely slow rate of fire.
- **Batons** — thrown like grenades, roughly cricket-bat physics.
- **Truthbomb (NHS Double Decker Bus)** — the final research before the Rocket Silo. Deploys as a massive explosion, accompanied by Michael Caine: _"You were only supposed to blow the bloody doors off."_

## Medkit (NHS)

- Free to craft.
- 30-minute craft time — long enough to demand factory planning.
- 30–120 second activation delay between use and effect (randomised per use).
- On activation, fully heals **every player on the map** — the NHS treats the whole nation, not just the patient.
- Single global heal timer: only one outstanding heal exists at a time. Using a medkit while one is already queued **resets** the timer rather than enqueueing a second one.

## Research

The visible tech tree leans into British memes, gating absurd capabilities behind expensive prerequisites.

- **Yer'a Wizard 'Arry** — unlocks the **Wand**, which in turn enables a research branch of spells:
  - **Petrificus Totalus** — turns the target to stone.
  - **Abra Kadabra** — nuclear explosion centred on the player.
  - **Avada Kedavra** — fires a Tesla turret bolt.
- **Philosopher's Stone** — required prerequisite to unlock the **Tank**.
- **Mr. Blobby** — extremely expensive, late-game tech. Required for the win condition (firing Mr. Blobby into space). Toggled by a **runtime mod setting** (changeable during a running game), with prominent warnings on flip. The **You Whimp** achievement is granted only when the setting is **flipped off during a running game** — picking the setting before starting a fresh save does not qualify. Disabling removes the win condition for that run.
- **Truthbomb (NHS Double Decker Bus)** — final pre-rocket research. See Weapons.

## Food cravings (On-Tick debuff)

Every player runs a three-stage debuff cycle from the first tick. Eating Cuppa Tea or Fish & Chips resets the cycle to Satiated.

- **Satiated** — duration `3600 ticks × 5–10` (one-minute Factorio ticks × randomised 5–10 multiplier). Ends with a forced random prompt: _Fish & Chips or Cuppa Tea?_
- **Craving** — duration `3600 ticks` (one minute). Final warning window.
- **Craven** — infinite. The factory is effectively disabled: a hidden beacon imposes an absurd electricity demand (e.g. 99,999,999,999,999,999) so nothing runs until food is consumed.

Reaching Craven grants the **Bloody Uncivilized** achievement.

## Audio

- Victory jingle replaced with _"Fuck this Shit I'm Out."_
- Tank loop: continuous "God Save the King" (bad recording — drunk yelling or similar).
- Truthbomb detonation: Michael Caine voice line.

## Biters

- Biters are reskinned as **Rambo** soldiers — GI helmets, medals.
- **Spitter nests** are reskinned as **Barrack Tents**.
- **Biter nests** are reskinned as **EU Buildings**.
- Biter AI prioritises **oil patches** first and other resource patches second.
- Dead biters drop an **EU Flag** on the ground:
  - Mining an EU Flag takes 30 seconds.
  - Bots cannot mine EU Flags — hand-mining only.

## Non-goals

- **No bot-friendly EU Flag mining.** The 30-second hand-mining cost is the point.
- **No skipping cravings.** The On-Tick debuff cannot be turned off in-game.
- **No alternate Mr. Blobby win.** If Mr. Blobby is disabled, the run has no win condition by design — the achievement is the consolation.

## Open / suggested features (not yet agreed)

These are bullets from the source doc that have not been signed off; they live here as a parking lot until agreed or rejected.

- _Insert your feature here_
- Beans
- Bacon & Egg

---

Implementation choices, internal entity names, and engine-level details live in [design.md](design.md).
