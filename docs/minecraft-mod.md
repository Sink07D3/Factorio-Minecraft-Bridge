# Minecraft mod (`FMCBridge`)

## Overview

- **Mod ID:** `fmcbridge` (`FMCBridge.java`).
- **Minecraft / Forge:** **1.12.2** (`build.gradle` → `1.12.2-14.23.5.2847`, MCP mappings `snapshot_20180814`).
- **Artifact:** `archivesBaseName` = `FMCBridge`, project `version` = `2.1.0` in Gradle.

## Blocks and tile entities

| Block | Java class | Role |
|-------|------------|------|
| Transfer Chest Sender | `TCSBlock` + `TCSEntity` | Single-slot inventory; collects items to send to the bridge. |
| Transfer Chest Receiver | `TCRBlock` + `TCREntity` | 27-slot inventory; receives items from the bridge. |

Registration occurs in `CommonProxy.registerBlocks` with `GameRegistry.registerTileEntity`.

### Sender (`TCSEntity`)

- Inventory size **1** (`SIZE = 1`).
- On world load, registers with `FMCBridge.instance.addTCS`. The **first** chest becomes **`manager`**; when `manager` is true, every **20 ticks** (≈1 s) it calls **`send()`**.
- **`send()`** walks **all** `TCSEntity` instances in `tcsEntityList`, builds `MinecraftItem` records (registry name, count, metadata, NBT list placeholder), clears source slots, and pushes the list to **`SocketThreadOutput.set_items`** if a socket connection exists.

### Receiver (`TCREntity`)

- Inventory size **27**.
- The **manager** TCR, every **20 ticks**, sets **`receiving`** and calls **`SocketThreadInput.try_receive(true)`** to unblock the input thread so it can read the next framed message.
- **`receive(ArrayList<MinecraftItem>)`** distributes items across chests: optional **item lock** string per chest (`lockedItem` in NBT), merges into partial stacks, respects metadata.

## Networking (`ItemQueues` + socket threads)

- **`ItemQueues`** constructor opens **`new Socket("127.0.0.1", 25575)`**.
- **`login`** sends a JSON **`BridgeCommand`** with `command_type` `"login"` and `command_body` username/password from `Config`.
- On success, starts **`SocketThreadInput`** and **`SocketThreadOutput`**.

### `SocketThreadInput`

- Waits on a flag, then reads a **length-prefixed UTF-8 JSON** message (4-byte big-endian length, then payload).
- Parses top-level `rec_type` and `rec_objects`; for `rec_type` **`item`**, deserializes a list of **`MinecraftItem`** and calls **`FMCBridge.instance.receieveManager.receive(items)`**.

### `SocketThreadOutput`

- When **`set_items`** is called with a non-empty list, serializes the **`ArrayList<MinecraftItem>`** with Gson and writes via **`DataOutputStream.writeUTF`** (Java modified UTF-8 framing—not the same as the 4-byte length framing used on input).

**Integration note:** The read path uses 4-byte length framing; the write path uses `writeUTF`. Any bridge server must match this asymmetry or the mod must be updated for a single consistent protocol.

## Configuration

- **`Config.java`** reads `fmcbridge.cfg` via Forge `Configuration` in `CommonProxy.preInit`.
- Category **`authentication`**: `username` and **`realName`** (password).

## Lifecycle

- **`WorldLoadEvent`:** Resets entity maps and constructs **`ItemQueues`** if not already logged in.
- **`FMLServerStoppingEvent`:** Clears maps, stops socket threads, closes the socket.

## Building

From `FMCBridge/`:

```text
gradlew build
```

Use the Forge Gradle version pinned in `build.gradle` (ForgeGradle 2.3 for 1.12.2). JDK 8 matches `sourceCompatibility` / `targetCompatibility` **1.8**.

## Commands

`BridgeCommand.java` and `ItemCommand.java` exist for additional debugging; see source for registered commands and permissions.
