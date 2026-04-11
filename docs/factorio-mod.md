# Factorio mod (`transfer-chest`)

## Metadata

- **Folder:** `Factorio/transfer-chest_2.0.0/`
- **`info.json`:** name `transfer-chest`, version `2.0.0`, `factorio_version` **2.0**, dependency `base >= 0.16` (update `dependencies` if you target a specific Factorio 2.0 base version).

## Contents

| File | Role |
|------|------|
| `data.lua` | Loads `prototypes/item.lua`. |
| `prototypes/item.lua` | Defines entities, items, recipes for **send-chest** and **receive-chest**. |
| `control.lua` | Runtime logic: chest tracking, file output, remote interface, debug command. |

## Entities

- **`send-chest`:** `type = "container"`, **`inventory_size = 1`**. Used for exporting items toward Minecraft.
- **`receive-chest`:** `type = "container"`, **`inventory_size = 50`** (Lua) — note this differs from Minecraft’s 27-slot receiver; the bridge maps by item name/count only.

Recipes use **wood** and **iron-plate** in the prototype file.

## Placement hooks

`on_built_entity` / `on_robot_built_entity` replace the built entity with a new instance of the same name and add it to **`storage.transferChests`**. On removal events, entries are cleared from that list.

## Tick loop (export)

Every **60 ticks** (~1 second at 60 UPS), for each **send-chest** in `storage.transferChests`:

- If the chest inventory is not empty, append **`inventory[1].name .. ":" .. inventory[1].count`** to a string (first slot only).
- Clear the inventory.
- **`helpers.write_file("toMC.dat", saveString)`** — output goes to Factorio’s **script output** directory for the running instance.

Downstream, the Windows bridge reads this as **`script-output\toMC.dat`** under the Factorio path configured in `settings.json`.

## Remote interface (import)

```lua
remote.add_interface("receiveItems", {
  inputItems = function(itemName, c)
    -- inserts into first receive-chest that can accept
  end
})
```

The bridge calls this via RCON **`/silent-command remote.call("receiveItems","inputItems", "<name>", <count>)`** (see `Program.cs`).

## Debug command

`commands.add_command("itemData", ...)` prints the **internal item name** of the held stack so you can align `item_mappings.txt` with Factorio names.

## Assets

The prototypes reference graphics under `__transfer-chest__/graphics/`. Ensure the mod zip includes those PNGs (this repository listing may omit binary assets; add them when packaging).

## Compatibility notes

- **`storage`** global is Factorio **2.0** script API style; if you port to older Factorio, replace with `global` and adjust migration.
- Verify **`factorio_version`** and `dependencies` in `info.json` against your Factorio install.
