# Bridge application (.NET)

## Projects in this repository

### `Bridge/Factorio_MC_Bridge/Factorio_MC_Bridge` (main console bridge)

**Entry point:** `Program.Main` in `Program.cs`.

**Behavior (summary):**

1. Optionally interactively creates or loads **`settings.json`**.
2. Loads **`item_mappings.txt`** into a `DualDictionary<string,string>` plus optional ratio maps for Minecraft and Factorio.
3. Enters an infinite loop (1 second sleep) that:
   - **`parseFactrio`** — reads Factorio’s `script-output\toMC.dat` (path from settings), parses `item:count` lines, applies ratio and stack-splitting logic, maps names through the Factorio side of the dictionary to Minecraft names.
   - **`parseMinecraft`** — reads **`toFactorio.dat`** under the Minecraft root path, lines `name~count`, applies ratios, maps to Factorio names, clears the file after read.
   - **`sendToFactorio`** — for each pending stack, issues RCON `/silent-command remote.call("receiveItems","inputItems",...)` with chunks of at most **100** per call when count exceeds 100.
   - **`sendToMinecraft`** — appends lines to **`fromFactorio.dat`**.

**Dependencies (NuGet):** CoreRCON, Newtonsoft.Json, and supporting BCL packages (see `.csproj`).

**Build:** Open `Bridge/Factorio_MC_Bridge/Factorio_MC_Bridge.sln` in Visual Studio or use MSBuild; restore NuGet packages first.

### `Bridge/FMC_Bridge_Core/Factorio_MC_Bridge`

**Entry point:** `async Task Main` in `Program.cs` (different from the simple console bridge).

**Behavior:**

- Starts two threads: **`MinecraftThread`** (TCP listen on `127.0.0.1:25575`, login handshake, `OutputThread` / `InputThread`) and **`FactorioThread`** (RCON to `127.0.0.1:25555` with hardcoded password in the sample).
- Console commands `send_mc`, `send_f`, `receive_r` toggle test behavior.
- Contains **copies** of `sendToFactorio` / `parseFactrio` / `parseMinecraft` / `sendToMinecraft` with **empty `fullPath` strings** in the copy—those regions are **not wired** for production use as-is.

Use this project as a **development sandbox** for socket + RCON integration, not as a drop-in replacement for the file bridge without further work.

### `Bridge/FMC_Bridge_Core/.../SettingsAndMappings`

A **Windows Forms** shell (`Form1`) with no business logic yet—reserved for editing settings/mappings in a GUI.

## Notable implementation details

- **`parseFactrio` typo:** Method name is spelled `parseFactrio` throughout.
- **`DualDictionary` indexers:** Exposed as `minecraft` and `facotrio` (typo preserved in code).
- **Async void:** `sendToFactorio` is `async void`; exceptions may not surface cleanly to the main loop (the outer `catch` in `Main` may not observe them).

## Security

- RCON passwords and file paths live in plain JSON/text files.
- The TCP listener in `FMC_Bridge_Core` binds to localhost in the sample but has no authentication beyond the Minecraft mod’s login JSON—do not expose unauthenticated bridge ports to untrusted networks.
