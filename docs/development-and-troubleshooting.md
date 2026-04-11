# Development and troubleshooting

## Building from source

### Minecraft mod (`FMCBridge`)

1. Install **JDK 8** and ensure `JAVA_HOME` is set if your environment requires it.
2. From `FMCBridge/`, run the Gradle wrapper (e.g. `gradlew.bat build` on Windows).
3. Output mod JAR is typically under `build/libs/`.
4. For IDE setup, use Forge’s documented `gradlew setupDecompWorkspace` / `eclipse` or `idea` tasks for this Gradle/Forge version.

### Bridge (`Factorio_MC_Bridge`)

1. Open `Bridge/Factorio_MC_Bridge/Factorio_MC_Bridge.sln` in Visual Studio.
2. Restore NuGet packages (right-click solution → Restore NuGet Packages, or automatic on build).
3. Build **Release** or **Debug**; executable lands in `bin\Debug` or `bin\Release`.

### Factorio mod

1. Ensure `graphics/` assets exist for icons and entity sprites referenced in `prototypes/item.lua`.
2. Zip the mod folder so the root contains `info.json`, `data.lua`, `control.lua`, `prototypes/`, `graphics/`.
3. Install via Factorio’s mod directory or symlink for development.

## Testing the classic file pipeline

1. Start Factorio with **transfer-chest** enabled; place a **send-chest**, insert a known item.
2. Confirm **`script-output\toMC.dat`** updates (path depends on user data directory).
3. Point the bridge `factorioPath` at that user data root (the parent of `script-output`).
4. Run the bridge; watch console for errors instead of `"Something went wrong"`.
5. Inspect **`fromFactorio.dat`** under `mcPath` for mapped Minecraft names.

## Common issues

### Empty or missing `toMC.dat`

- Mod not loaded, no **send-chest** placed, or inventories empty.
- Wrong **`factorioPath`** (must include the folder that contains **`script-output`**).
- Factorio sandbox/script output disabled or different in headless mode—check Factorio documentation for `script-output` location.

### RCON connection failures

- Wrong IP/port/password in `settings.json`.
- Firewall blocking RCON.
- Server not started or mod not present (remote interface missing → command may fail).

### `item_mappings.txt` errors / wrong items

- Names must match **Factorio internal** and **Minecraft registry** strings exactly.
- Use Factorio **`itemData`** command (cursor stack) and Minecraft registry names from mods or `/give` tab completion.

### Minecraft mod does not connect

- Nothing listening on **`127.0.0.1:25575`** — start the bridge variant that implements the TCP server, or expect connection failure (exceptions may be swallowed in `ItemQueues` constructor).
- **Login** mismatch between `fmcbridge.cfg` and bridge server.

### File locked (`IOException`) on `toFactorio.dat`

The bridge **retries** opening `toFactorio.dat` with `FileShare.None` in a loop; if Minecraft holds the file open differently, you can still see stalls. Ensure only one writer/reader pair uses the file as designed.

### Protocol mismatch (socket)

If you enable socket mode, verify:

- Java **login** framing (`writeUTF`) vs C# **Receive** (2-byte length) vs Java **input** (4-byte length).
- Documented in [Data formats and protocols](data-formats-and-protocols.md); fix one side or add a small compatibility shim.

## Contributing notes

- Prefer minimal, focused changes; the codebase mixes **production** (`Factorio_MC_Bridge` file loop) and **experimental** (`FMC_Bridge_Core`) paths—avoid breaking the file-based workflow unless intentionally migrating.
