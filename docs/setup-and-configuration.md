# Setup and configuration

## Prerequisites

- **Windows** (the bridge is a .NET Framework desktop/console app; paths use backslashes in code).
- **Factorio** with the ability to install local mods and enable **RCON** on the server you target.
- **Minecraft Java Edition** server or client with **Forge 1.12.2** matching `FMCBridge/build.gradle` if you use the mod.
- **.NET Framework 4.6.1** or compatible runtime for building/running the bridge (see project file).

## Factorio server: RCON

The classic bridge (`Bridge/Factorio_MC_Bridge`) sends commands such as:

```text
/silent-command remote.call("receiveItems","inputItems","<itemName>",<count>)
```

You must configure the Factorio dedicated server (or equivalent) with:

- RCON **port** (user-defined; must match `settings.json`).
- RCON **password** (must match `settings.json`).

Exact Factorio version flags differ by release; refer to [Factorio’s multiplayer documentation](https://wiki.factorio.com/Multiplayer) for your version.

## Bridge: first-run `settings.json`

When you run `Factorio_MC_Bridge`, it can create **`settings.json`** in the **current working directory** (the folder from which you start the executable). On first run (or when you choose to reconfigure), it prompts for:

| Field | Meaning |
|-------|---------|
| Minecraft location | **Root directory** of the Minecraft server (or the folder where `toFactorio.dat` and `fromFactorio.dat` will live). |
| Factorio server path | **Root** used to resolve `script-output\toMC.dat` (typically the Factorio user data directory containing `script-output`). |
| IP address | Factorio server address for RCON. |
| RCON port | As configured on the server. |
| RCON password | As configured on the server. |

The `Settings` class (`Bridge/Factorio_MC_Bridge/Factorio_MC_Bridge/Settings.cs`) serializes these fields as JSON via Newtonsoft.Json.

## Item mappings: `item_mappings.txt`

Place **`item_mappings.txt`** next to the bridge executable (same folder as `settings.json`). Format:

- One mapping per line: `minecraftName=factorioName` optionally followed by ratio data `=mcRatio:facRatio` (see parsing in `Program.cs`).
- Lines containing `#` or empty lines are skipped.

The bridge uses `DualDictionary` so each side can resolve the opposite name when converting outgoing lists.

**Important:** Every item you transfer must appear in this file with correct names:

- Minecraft: registry names like `minecraft:iron_ingot`.
- Factorio: internal item names like `iron-plate`.

## Minecraft mod: `fmcbridge.cfg`

Generated under the Forge config directory (see `CommonProxy.preInit`): category **`authentication`**.

| Key | Purpose |
|-----|---------|
| `username` | Sent in the JSON login command to the bridge TCP server. |
| `realName` | Used as the **password** field in config (despite the label—see `Config.initAuthConfig`). |

Defaults are placeholder `username` / `password`; change them to match whatever your bridge socket server expects.

## Run order (recommended)

1. Start **Factorio** (or dedicated server) with the **transfer-chest** mod and RCON enabled.
2. Start **Minecraft** with **FMCBridge** if you use the mod.
3. Start the **bridge** executable from a working directory where `settings.json` and `item_mappings.txt` are found.
4. Verify `script-output\toMC.dat` appears when you put items in **send-chest** entities.

## Firewall and localhost

- RCON uses the **Factorio host/port** you configured (often LAN or localhost).
- The Minecraft mod connects to **`127.0.0.1:25575`**; if you run the bridge TCP listener on another machine, you must change the Java code or use networking/port forwarding (not configurable in `Config` alone).
