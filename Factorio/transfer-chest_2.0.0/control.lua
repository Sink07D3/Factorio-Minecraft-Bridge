require "util"

local function ONLOAD()
    storage.transferChests = storage.transferChests or {}
end

--- Collect first stack from each send-chest, clear inventories, return same text format as legacy file (name:count per line).
local function collect_from_send_chests()
    local save_string = ""
    for _, send in pairs(storage.transferChests) do
        if send.valid and send.name == "send-chest" then
            local inventory = send.get_inventory(defines.inventory.chest)
            if inventory and not inventory.is_empty() then
                local stack = inventory[1]
                if stack and stack.valid_for_read then
                    save_string = save_string .. stack.name .. ":" .. stack.count .. "\n"
                    inventory.clear()
                end
            end
        end
    end
    return save_string
end

local function ONBUILD(event)
    local entity = event.entity
    if entity.name == "send-chest" then
        local surface = entity.surface
        local force = entity.force
        local new_send = surface.create_entity { name = "send-chest", position = entity.position, force = force }
        entity.destroy()
        table.insert(storage.transferChests, new_send)
    elseif entity.name == "receive-chest" then
        local surface = entity.surface
        local force = entity.force
        local new_rec = surface.create_entity { name = "receive-chest", position = entity.position, force = force }
        entity.destroy()
        table.insert(storage.transferChests, new_rec)
    end
end

local function ONREMOVE(event)
    local entity = event.entity
    if entity.name == "send-chest" then
        for index, l in pairs(storage.transferChests) do
            if entity == l then
                storage.transferChests[index] = nil
                break
            end
        end
    elseif entity.name == "receive-chest" then
        for index, l in pairs(storage.transferChests) do
            if entity == l then
                storage.transferChests[index] = nil
                break
            end
        end
    end
end

script.on_init(ONLOAD)

commands.add_command("itemData", { "cmd.find-item" }, function(event)
    local player = game.players[event.player_index]
    if player.cursor_stack.valid_for_read then
        player.print(player.cursor_stack.name)
    else
        player.print("You need to be holding an item!")
    end
end)

script.on_event(defines.events.on_built_entity, ONBUILD)
script.on_event(defines.events.on_robot_built_entity, ONBUILD)
script.on_event(defines.events.on_pre_player_mined_item, ONREMOVE)
script.on_event(defines.events.on_robot_pre_mined, ONREMOVE)
script.on_event(defines.events.on_entity_died, ONREMOVE)

-- Legacy: periodic file export (optional via runtime-global mod setting). Bridge default is RCON pull instead.
script.on_event({ defines.events.on_tick }, function(e)
    if e.tick % 60 ~= 0 then
        return
    end
    if not settings.global["transfer-chest-legacy-file-export"].value then
        return
    end
    helpers.write_file("toMC.dat", collect_from_send_chests())
end)

-- RCON /silent-command: remote.call("exportItems", "pull") — returns export text and clears send chests (same as file export).
remote.add_interface("exportItems", {
    pull = function()
        return collect_from_send_chests()
    end
})

remote.add_interface("receiveItems", {
    -- Insert items, returns the number so items can be adjusted
    inputItems = function(itemName, c)
        local itemsToInsert = { name = itemName, count = c }
        for _, rec in pairs(storage.transferChests) do
            if rec.valid and rec.name == "receive-chest" then
                local inventory = rec.get_inventory(defines.inventory.chest)
                if inventory and inventory.can_insert(itemsToInsert) then
                    return inventory.insert(itemsToInsert)
                end
            end
        end
    end
})
