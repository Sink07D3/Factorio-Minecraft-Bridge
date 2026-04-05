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
        table.insert(storage.transferTanks, entity)
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
        table.insert(storage.transferTanks, entity)
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
script.on_load(ONLOAD)

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
    Send chests, tanks (fluids), accumulators — one line each "name:amount" to toMC.dat.
    Tanks export Factorio fluid names and amounts (fluid units), not item stacks.
]]
script.on_event({defines.events.on_tick},
    function(e)
        if e.tick % 60 ~= 0 then
            return
        end
        local saveString = ""
        for _, send in pairs(storage.transferChests) do
            if send.valid and send.name == "send-chest" then
                local inventory = send.get_inventory(defines.inventory.chest)
                if not inventory.is_empty() then
                    saveString = saveString .. inventory[1].name .. ":" .. inventory[1].count .. "\n"
                    inventory.clear()
                end
            end
        end
        for _, send in pairs(storage.transferTanks) do
            if send.valid and send.name == "send-tank" then
                local fluid = send.fluidbox[1]
                if fluid and fluid.name then
                    local amt = fluid.amount
                    saveString = saveString .. fluid.name .. ":" .. tostring(math.floor(amt)) .. "\n"
                    send.fluidbox[1] = nil
                end
            end
        end
        for _, send in pairs(storage.transferAccumulators) do
            if send.valid and send.name == "send-accumulator" then
                local inventory = send.get_inventory(defines.inventory.accumulator)
                if not inventory.is_empty() then
                    saveString = saveString .. inventory[1].name .. ":" .. inventory[1].count .. "\n"
                    inventory.clear()
                end
            end
        end
        helpers.write_file("toMC.dat", saveString)
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


-- Receive Tank (fluids: Factorio fluid name + amount in fluid units)
remote.add_interface("receiveTanks", {
    inputTanks = function(fluidName, amount)
        if not fluidName or type(fluidName) ~= "string" then
            return 0
        end
        amount = amount or 0
        if amount <= 0 then
            return 0
        end
        for _, rec in pairs(storage.transferTanks) do
            if rec.valid and rec.name == "receive-tank" then
                local inserted = rec.insert_fluid({name = fluidName, amount = amount})
                if inserted > 0 then
                    return inserted
                end
            end
        end
        return 0
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