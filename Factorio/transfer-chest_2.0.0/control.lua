require "util"
local function ONLOAD()
    storage.transferChests = storage.transferChests or {}
    storage.transferTanks = storage.transferTanks or {}
    storage.transferAccumulators = storage.transferAccumulators or {}
end

local function ONBUILD( event )
    local entity = event.entity
    if entity.name == "send-chest" then
        local surface = entity.surface
        local force = entity.force
        newSend = surface.create_entity{ name = "send-chest", position = entity.position, force = force }
        entity.destroy()
        table.insert( storage.transferChests, newSend )
    elseif entity.name == "send-tank" then
        local surface = entity.surface
        local force = entity.force
        newSend = surface.create_entity{ name = "send-tank", position = entity.position, force = force }
        entity.destroy()
        table.insert( storage.transferChests, newSend )
    elseif entity.name == "send-accumulator" then
        local surface = entity.surface
        local force = entity.force
        newSend = surface.create_entity{ name = "send-accumulator", position = entity.position, force = force }
        entity.destroy()
        table.insert( storage.transferChests, newSend )
    elseif entity.name == "receive-chest" then
        local surface = entity.surface
        local force = entity.force
        newRec = surface.create_entity{ name = "receive-chest", position = entity.position, force = force }
        entity.destroy()
        table.insert( storage.transferChests, newRec )
    elseif entity.name == "receive-tank" then
        local surface = entity.surface
        local force = entity.force
        newRec = surface.create_entity{ name = "receive-tank", position = entity.position, force = force }
        entity.destroy()
        table.insert( storage.transferChests, newRec )
    elseif entity.name == "receive-accumulator" then
        local surface = entity.surface
        local force = entity.force
        newRec = surface.create_entity{ name = "receive-accumulator", position = entity.position, force = force }
        entity.destroy()
        table.insert( storage.transferChests, newRec )
    end
end


local function ONREMOVE( event )
    local entity = event.entity
    if entity.name == "send-chest" then
        for index, l in pairs( storage.transferChests ) do
            if entity == l then
                storage.transferChests[index] = nil
                break
            end
        end
    elseif entity.name == "receive-chest" then
        for index, l in pairs( storage.transferChests ) do
            if entity == l then
                storage.transferChests[index] = nil
                break
            end
        end
    elseif entity.name == "send-tank" then
        for index, l in pairs( storage.transferTanks ) do
            if entity == l then
                storage.transferTanks[index] = nil
                break
            end
        end
    elseif entity.name == "receive-tank" then
        for index, l in pairs( storage.transferTanks ) do
            if entity == l then
                storage.transferTanks[index] = nil
                break
            end
        end
    elseif entity.name == "send-accumulator" then
        for index, l in pairs( storage.transferAccumulators ) do
            if entity == l then
                storage.transferAccumulators[index] = nil
                break
            end
        end
    elseif entity.name == "receive-accumulator" then
        for index, l in pairs( storage.transferAccumulators ) do
            if entity == l then
                storage.transferAccumulators[index] = nil
                break
            end
        end
    end
end




script.on_init(ONLOAD)

commands.add_command("itemData", {"cmd.find-item"}, function(event)
    local player = game.players[event.player_index]
    if player.cursor_stack.valid_for_read then
        player.print(player.cursor_stack.name)
    else
        player.print("You need to be holding an item!")
    end
end)

--script.on_init(ONLOADREC)

script.on_event( defines.events.on_built_entity, ONBUILD )
script.on_event( defines.events.on_robot_built_entity, ONBUILD )
script.on_event( defines.events.on_pre_player_mined_item, ONREMOVE )
script.on_event( defines.events.on_robot_pre_mined, ONREMOVE )
script.on_event( defines.events.on_entity_died, ONREMOVE )

--[[
script.on_event( defines.events.on_built_entity, ONBUILDREC )
script.on_event( defines.events.on_robot_built_entity, ONBUILDREC )
script.on_event( defines.events.on_pre_player_mined_item, ONREMOVEREC )
script.on_event( defines.events.on_robot_pre_mined, ONREMOVEREC )
script.on_event( defines.events.on_entity_died, ONREMOVEREC )
]]

--[[
    Send Chest, write to the file
]]
script.on_event({defines.events.on_tick}, 
    function (e)
        if e.tick % 60 == 0 then
            local saveString = ""
            temp = {}
            for k, send in pairs (storage.transferChests) do
                if send.name == "send-chest" then
                    local inventory = send.get_inventory(defines.inventory.chest)
                    if not inventory.is_empty() then
                        saveString = saveString .. inventory[1].name .. ":" .. inventory[1].count .. "\n"
                        inventory.clear();
                    end
                end
            end
            helpers.write_file("toMC.dat", saveString)
        end
    end
)
-- Send Tank
script.on_event({defines.events.on_tick}, 
    function (e)
        if e.tick % 60 == 0 then
            local saveString = ""
            temp = {}
            for k, send in pairs (storage.transferTanks) do
                if send.name == "send-tank" then
                    local inventory = send.get_inventory(defines.inventory.tank)
                    if not inventory.is_empty() then
                        saveString = saveString .. inventory[1].name .. ":" .. inventory[1].count .. "\n"
                        inventory.clear();
                    end
                end
            end
            helpers.write_file("toMC.dat", saveString)
        end
    end
)

-- Send Accumulator
script.on_event({defines.events.on_tick}, 
    function (e)
        if e.tick % 60 == 0 then
            local saveString = ""
            temp = {}
            for k, send in pairs (storage.transferAccumulators) do
                if send.name == "send-accumulator" then
                    local inventory = send.get_inventory(defines.inventory.accumulator)
                    if not inventory.is_empty() then
                        saveString = saveString .. inventory[1].name .. ":" .. inventory[1].count .. "\n"
                        inventory.clear();
                    end
                end
            end
            helpers.write_file("toMC.dat", saveString)
        end
    end
)

--[[
    Receive Chest, read from file. Things probably shouldnt be inserted here
]]
remote.add_interface("receiveItems",{

    --Insert items, returns the number so items can be adjusted
    inputItems = function(itemName, c)
        local itemsToInsert = {name=itemName, count=c}
        for k, rec in pairs (storage.transferChests) do
            if rec.name == "receive-chest" then
                local inventory = rec.get_inventory(defines.inventory.chest)
                if inventory.can_insert(itemsToInsert) then
                    return inventory.insert(itemsToInsert)
                end
            end
        end
    end
})


-- Receive Tank
remote.add_interface("receiveTanks",{
    inputTanks = function(itemName, c)
        local itemsToInsert = {name=itemName, count=c}
        for k, rec in pairs (storage.transferTanks) do
            if rec.name == "receive-tank" then
                local inventory = rec.get_inventory(defines.inventory.tank)
                if inventory.can_insert(itemsToInsert) then
                    return inventory.insert(itemsToInsert)
                end
            end
        end
    end
})

-- Receive Accumulator
remote.add_interface("receiveAccumulators",{
    inputAccumulators = function(itemName, c)
        local itemsToInsert = {name=itemName, count=c}
        for k, rec in pairs (storage.transferAccumulators) do
            if rec.name == "receive-accumulator" then
                local inventory = rec.get_inventory(defines.inventory.accumulator)
                if inventory.can_insert(itemsToInsert) then
                    return inventory.insert(itemsToInsert)
                end
            end
        end
    end
})