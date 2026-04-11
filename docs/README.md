# Factorio–Minecraft Bridge — Documentation

This repository connects **Factorio** and **Minecraft (Java Edition)** so items can move between the two games. The integration uses a **Windows .NET bridge application**, optional **file-based handoff**, and/or a **TCP protocol** between the bridge and the Minecraft mod.

## Documentation map

| Document | Contents |
|----------|----------|
| [Architecture](architecture.md) | How the pieces fit together, data flows, and deployment models |
| [Setup and configuration](setup-and-configuration.md) | Prerequisites, paths, RCON, config files, run order |
| [Bridge application (.NET)](bridge-application.md) | `Factorio_MC_Bridge` console app, settings, mappings |
| [Minecraft mod (Forge)](minecraft-mod.md) | `FMCBridge` — blocks, tile entities, sockets, build |
| [Factorio mod](factorio-mod.md) | `transfer-chest` — send/receive chests, Lua, script output |
| [Data formats and protocols](data-formats-and-protocols.md) | `toMC.dat`, `toFactorio.dat`, RCON calls, JSON/socket notes |
| [Development and troubleshooting](development-and-troubleshooting.md) | Building each component, test order, common failures |

## Repository layout (high level)

```
Factorio-Minecraft-Bridge/
├── Bridge/
│   ├── Factorio_MC_Bridge/          # Main file-based bridge (RCON + disk files)
│   └── FMC_Bridge_Core/             # Alternate/experimental bridge (sockets + RCON threads)
├── FMCBridge/                       # Minecraft Forge 1.12.2 mod (Java)
└── Factorio/
    └── transfer-chest_2.0.0/        # Factorio mod (Lua)
```

## Quick concept

1. **Factorio** places items into **send chests**; the mod periodically writes outgoing stacks to a script-output file (`toMC.dat`).
2. The **bridge** reads that file, maps Factorio item names to Minecraft registry names, and sends items toward Minecraft (via disk files in the classic design, or via the mod’s TCP connection in newer experiments).
3. **Minecraft** exposes **Transfer Chest Sender (TCS)** and **Transfer Chest Receiver (TCR)** blocks that talk to the bridge (socket) or legacy file paths when wired to the classic bridge.
4. Return traffic from Minecraft to Factorio follows the reverse path; the Factorio mod exposes **`receiveItems`** via `remote` so RCON can insert into **receive chests**.

For precise file names, field formats, and ports, see [Data formats and protocols](data-formats-and-protocols.md).

## Version notes

- **Minecraft mod**: Forge **1.12.2** (see `FMCBridge/build.gradle`).
- **Factorio mod**: `info.json` targets Factorio **2.0**; Lua uses `storage` global (Factorio 2.0 style). Validate against your installed Factorio version.
- **Bridge**: .NET Framework **4.6.1** (main `Factorio_MC_Bridge` project).
