# transfer-chest (Factorio–Minecraft bridge mod)

Factorio **2.0** mod that exposes **send** and **receive** buildings for moving **items**, **fluids**, and **electric energy** to an external process (e.g. a C# bridge and Minecraft) using:

- **`script-output/toMC.dat`** — Factorio → bridge (written by the game)
- **`remote.call(...)` via RCON** — bridge → Factorio (read by the game)

Send buildings use a **blue** tint; receive buildings use a **red** tint.

---

## Entities

| Role | Entity | Type | Notes |
|------|--------|------|--------|
| Send item | `send-chest` | `container` | 1 slot; contents exported each tick cycle |
| Receive item | `receive-chest` | `container` | 50 slots; filled via `receiveItems` |
| Send fluid | `send-tank` | `storage-tank` | Real fluid box + pipes (25k volume, vanilla-style connections) |
| Receive fluid | `receive-tank` | `storage-tank` | Filled via `receiveTanks` |
| Send power | `send-accumulator` | `accumulator` | 5 MJ buffer, 300 kW in/out, tertiary; exports joules under a fixed key |
| Receive power | `receive-accumulator` | `accumulator` | Same electrical stats; filled via `receiveAccumulators` |

Recipes use placeholder costs (wood + iron plates); change them in `prototypes/item.lua` for your pack.

---

## Runtime: export cadence

Every **60 ticks** (~**1 second** at 60 UPS), the mod:

1. **Send chests** — If `send-chest` has items, appends one line per stack line: `item-name:count`, then clears that inventory.
2. **Send tanks** — For each `send-tank`, may remove fluid (see **export budget** below) and append `fluid-name:amount` (fluid units, integer).
3. **Send accumulators** — May remove stored energy and append `electric-energy:joules` (integer joules).

All lines are concatenated into a single write to **`toMC.dat`** in the user’s **`script-output`** directory (same folder Factorio uses for `helpers.write_file`).

---

## `toMC.dat` line format

One record per line:

```text
<name>:<amount>
```

- **Items** — `name` is a Factorio item prototype name; `amount` is item count.
- **Fluids** — `name` is a Factorio fluid name (e.g. `water`, `crude-oil`); `amount` is fluid units.
- **Energy** — `name` is always **`electric-energy`**; `amount` is **joules** stored in the accumulator buffer at export time.

Lines from chests, tanks, and accumulators can all appear in the **same** file in one export cycle.

---

## Export budget (backpressure)

Factorio scripts **cannot read arbitrary files** from disk, so the bridge must tell the game how much fluid and energy it is allowed to pull **per export cycle** using RCON:

```text
/silent-command remote.call("transferBridge", "setExportBudget", max_fluid_units, max_energy_joules)
```

| Argument | Meaning |
|----------|---------|
| `max_fluid_units` | **Total** fluid units that may be removed from **all** `send-tank` entities this cycle, split in entity iteration order until the budget is used. |
| `max_energy_joules` | **Total** joules that may be removed from **all** `send-accumulator` entities this cycle. |
| **`nil`** for either argument | **No limit** for that type (default until you set otherwise — full drain each cycle when something is stored). |
| **`0`** | Do not export that type this cycle; fluid stays in tanks / energy stays in accumulators so they **keep filling** from pipes or the grid. |

Call this **from your bridge** each loop with the remaining capacity of your Minecraft buffer (or equivalent). If you never call it, caps stay **unset** and behavior matches “drain everything available each cycle” for fluids and energy.

---

## Remote interfaces (bridge → Factorio)

All interfaces are registered with `remote.add_interface`. Invoke from **console** or **RCON** with `/silent-command remote.call("InterfaceName", "methodName", ...)`.

### `transferBridge`

| Method | Arguments | Purpose |
|--------|-----------|---------|
| `setExportBudget` | `max_fluid_units`, `max_energy_joules` | Sets per-cycle export caps (see above). |

### `receiveItems`

| Method | Arguments | Returns |
|--------|-----------|---------|
| `inputItems` | `item_name`, `count` | Number of items inserted into the first `receive-chest` that can accept the stack; **0** if none. |

### `receiveTanks`

| Method | Arguments | Returns |
|--------|-----------|---------|
| `inputTanks` | `fluid_name`, `amount` | Fluid units inserted into the first `receive-tank` that accepts fluid; **0** if none. |

### `receiveAccumulators`

| Method | Arguments | Returns |
|--------|-----------|---------|
| `inputAccumulators` | `joules` **or** `unused, joules` | Joules added to the first `receive-accumulator` with free buffer; **0** if none. Second form supports legacy two-argument calls. |

**RCON examples**

```text
/silent-command remote.call("receiveItems", "inputItems", "iron-plate", 100)
/silent-command remote.call("receiveTanks", "inputTanks", "water", 1000)
/silent-command remote.call("receiveAccumulators", "inputAccumulators", 500000)
/silent-command remote.call("transferBridge", "setExportBudget", 5000, 2000000)
```

---

## Building registration

- **Tanks** and **accumulators** — The placed entity is tracked directly (no destroy/recreate).
- **Chests** — On build, the script still replaces the entity once (legacy behavior) so the chest is re-created for script bookkeeping; do not rely on this for dupe-free speedruns.

Entities are removed from internal lists on mine/robot mine/death.

---

## Multiplayer and saves

- Uses Factorio **`storage`** (persisted in saves).
- **`transferBridge` budgets** are stored in `storage` and persist across save/load until changed by RCON.
- External **`toMC.dat`** is written only on the machine running the script (dedicated server = server’s `script-output`).

---

## Files in this mod

| Path | Role |
|------|------|
| `info.json` | Mod metadata and Factorio version. |
| `data.lua` | Loads `prototypes/item.lua`. |
| `prototypes/item.lua` | All entity/item/recipe definitions. |
| `control.lua` | Events, export tick, remote interfaces. |
| `locale/en/locale.cfg` | English names and descriptions. |

---

## Troubleshooting

- **`toMC.dat` empty** — No send buildings with content, or export budget is `0` for fluids/energy, or nothing in send chests.
- **Fluids not moving** — Check `send-tank` / `receive-tank` are wired to pipes; verify RCON fluid name matches a valid Factorio fluid prototype.
- **Energy not moving** — Accumulators must be on an **electric network** to charge; export key for energy is always **`electric-energy`** in `toMC.dat`.
- **Mappings** — Any external tool that maps Factorio names to Minecraft names must include **fluid names** and **`electric-energy`**, not only item IDs.

---

## License / attribution

Uses Factorio **base** mod graphics and sounds via `__base__` paths. Ensure your distribution complies with Factorio’s modding and asset rules.
