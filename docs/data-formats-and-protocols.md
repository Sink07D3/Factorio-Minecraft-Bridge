# Data formats and protocols

## File: Factorio → bridge (`toMC.dat`)

- **Location (Factorio):** Written by `helpers.write_file("toMC.dat", ...)` → appears under **script output** for the game instance.
- **Location (bridge):** Joined as `Path.Combine(settings.getFactorioPath(), "script-output\\toMC.dat")` in `Bridge/Factorio_MC_Bridge` (Windows path separator in code).

**Line format:** one export per contributing send chest per tick batch in the shipped `control.lua`:

```text
<factorio-internal-item-name>:<count>
```

Example: `iron-plate:100`

The Lua builds a string by reading **only the first stack** in each non-empty send chest (`inventory[1]`).

## File: Minecraft → bridge (`toFactorio.dat`)

- **Path:** `Path.Combine(settings.getMcPath(), "toFactorio.dat")`.

**Line format:**

```text
<minecraft-registry-name>~<count>
```

The bridge splits on `~`, applies optional ratio from `item_mappings.txt`, then maps the Minecraft name to Factorio via the dual dictionary.

After reading, the bridge **truncates the file** (`File.WriteAllText(fullPath, string.Empty)`).

## File: bridge → Minecraft (`fromFactorio.dat`)

- **Path:** `Path.Combine(settings.getMcPath(), "fromFactorio.dat")`.

**Line format (append):**

```text
<minecraft-registry-name>~<count>
```

Written in `sendToMinecraft` after mapping from Factorio names.

## Item mappings file (`item_mappings.txt`)

Non-comment, non-empty lines:

```text
<minecraftName>=<factorioName>
```

Optional third segment (see `Program.cs` split logic):

```text
<minecraftName>=<factorioName>=<mcRatio>:<facRatio>
```

Ratios multiply the parsed count when the respective dictionary has entries.

Comment lines contain `#` or are blank.

## RCON (Factorio)

Used by **`sendToFactorio`**:

```text
/silent-command remote.call("receiveItems","inputItems","<factorioItemName>",<integerCount>)
```

Counts over **100** are split into multiple RCON calls of 100 until the remainder is sent.

The Factorio mod must expose **`receiveItems.inputItems`** (see `control.lua`).

## TCP / JSON (Minecraft mod ↔ bridge experiment)

### Login (Java client)

`ItemQueues.login` builds:

```json
{"command_type":"login","command_body":{"username":"<Config.username>","password":"<Config.password>"}}
```

It sends this with **`DataOutputStream.writeUTF`** (Java modified UTF-8 length prefix).

The **`FMC_Bridge_Core`** sample server uses a **2-byte big-endian** length prefix and UTF-8 payload for `Receive`/`Send`—this does **not** match `writeUTF` framing. Align client and server before relying on login.

### Inbound to Minecraft (`SocketThreadInput`)

After notification, the input thread reads **4-byte big-endian** length, then UTF-8 JSON. Expected structure includes:

- `rec_type` — e.g. `"item"`.
- `rec_objects` — JSON array of **`MinecraftItem`** objects.

### Outbound from Minecraft (`SocketThreadOutput`)

`SocketThreadOutput` calls **`writer.writeUTF(json)`** on the serialized list of **`MinecraftItem`**.

## `MinecraftItem` (Java)

Defined in `com.dongle.utils.MinecraftItem` (fields used in Gson deserialization): includes **`itemName`**, **`count`**, **`metadata`**, **`nbt`** (list of strings / optional NBT handling).

## Operational checklist

1. **`toMC.dat`** is created/updated when Factorio send chests have items and the game is running the mod.
2. **`settings.json`** `factorioPath` points at the directory that contains **`script-output\toMC.dat`**.
3. **`settings.json`** `mcPath` is the directory containing **`toFactorio.dat`** / **`fromFactorio.dat`** if you use the file bridge.
4. **`item_mappings.txt`** covers every item name appearing in both games.
