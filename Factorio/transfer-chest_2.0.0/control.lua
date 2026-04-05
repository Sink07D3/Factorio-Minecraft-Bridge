--[[
  transfer-chest — runtime control
  See README.md in this mod folder for bridge protocol, remotes, and file formats.
]]

local ACCUMULATOR_EXPORT_NAME = "electric-energy"

local function take_fluid_amount(entity, max_amount)
    local f = entity.fluidbox[1]
    if not f or not f.name or max_amount <= 0 then
        return 0, nil
    end
    local take = math.min(f.amount, max_amount)
    if take <= 0 then
        return 0, nil
    end
    if take >= f.amount then
        entity.fluidbox[1] = nil
    else
        entity.fluidbox[1] = {
            name = f.name,
            amount = f.amount - take,
            temperature = f.temperature
        }
    end
    return take, f.name
end

local function take_energy_amount(entity, max_joules)
    local j = entity.energy or 0
    if j <= 0 or max_joules <= 0 then
        return 0
    end
    local take = math.min(j, max_joules)
    entity.energy = j - take
    return take
end

local function remove_entity_from_list(list, entity)
    for index, ent in pairs(list) do
        if ent == entity then
            list[index] = nil
            break
        end
    end
end

local function ONLOAD()
    storage.transferChests = storage.transferChests or {}
    storage.transferTanks = storage.transferTanks or {}
    storage.transferAccumulators = storage.transferAccumulators or {}
end

local function ONBUILD(event)
    local entity = event.entity
    local name = entity.name
    if name == "send-chest" then
        local surface = entity.surface
        local force = entity.force
        local new_send = surface.create_entity({name = "send-chest", position = entity.position, force = force})
        entity.destroy()
        table.insert(storage.transferChests, new_send)
    elseif name == "send-tank" then
        table.insert(storage.transferTanks, entity)
    elseif name == "send-accumulator" then
        table.insert(storage.transferAccumulators, entity)
    elseif name == "receive-chest" then
        local surface = entity.surface
        local force = entity.force
        local new_rec = surface.create_entity({name = "receive-chest", position = entity.position, force = force})
        entity.destroy()
        table.insert(storage.transferChests, new_rec)
    elseif name == "receive-tank" then
        table.insert(storage.transferTanks, entity)
    elseif name == "receive-accumulator" then
        table.insert(storage.transferAccumulators, entity)
    end
end

local function ONREMOVE(event)
    local entity = event.entity
    local name = entity.name
    if name == "send-chest" or name == "receive-chest" then
        remove_entity_from_list(storage.transferChests, entity)
    elseif name == "send-tank" or name == "receive-tank" then
        remove_entity_from_list(storage.transferTanks, entity)
    elseif name == "send-accumulator" or name == "receive-accumulator" then
        remove_entity_from_list(storage.transferAccumulators, entity)
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

script.on_event(defines.events.on_built_entity, ONBUILD)
script.on_event(defines.events.on_robot_built_entity, ONBUILD)
script.on_event(defines.events.on_pre_player_mined_item, ONREMOVE)
script.on_event(defines.events.on_robot_pre_mined, ONREMOVE)
script.on_event(defines.events.on_entity_died, ONREMOVE)

-- Export to script-output/toMC.dat every 60 ticks (~1 s at 60 UPS). See README.md.
script.on_event({defines.events.on_tick}, function(e)
    if e.tick % 60 ~= 0 then
        return
    end
    local lines = {}
    local function append_line(s)
        lines[#lines + 1] = s
    end

    for _, send in pairs(storage.transferChests) do
        if send.valid and send.name == "send-chest" then
            local inventory = send.get_inventory(defines.inventory.chest)
            if not inventory.is_empty() then
                append_line(inventory[1].name .. ":" .. inventory[1].count)
                inventory.clear()
            end
        end
    end

    local f_cap = storage.bridge_fluid_export_cap
    local fluid_left = (f_cap == nil) and math.huge or math.max(0, f_cap)
    for _, send in pairs(storage.transferTanks) do
        if send.valid and send.name == "send-tank" and fluid_left > 0 then
            local fluid = send.fluidbox[1]
            if fluid and fluid.name then
                local take, fname
                if f_cap == nil then
                    take = fluid.amount
                    fname = fluid.name
                    send.fluidbox[1] = nil
                else
                    take, fname = take_fluid_amount(send, fluid_left)
                end
                if take and take > 0 and fname then
                    append_line(fname .. ":" .. tostring(math.floor(take)))
                    if f_cap ~= nil then
                        fluid_left = fluid_left - take
                    end
                end
            end
        end
    end

    local e_cap = storage.bridge_energy_export_cap
    local energy_left = (e_cap == nil) and math.huge or math.max(0, e_cap)
    for _, send in pairs(storage.transferAccumulators) do
        if send.valid and send.name == "send-accumulator" and energy_left > 0 then
            local joules = send.energy or 0
            if joules > 0 then
                local take
                if e_cap == nil then
                    take = joules
                    send.energy = 0
                else
                    take = take_energy_amount(send, energy_left)
                end
                if take > 0 then
                    append_line(ACCUMULATOR_EXPORT_NAME .. ":" .. tostring(math.floor(take)))
                    if e_cap ~= nil then
                        energy_left = energy_left - take
                    end
                end
            end
        end
    end

    local payload = #lines > 0 and (table.concat(lines, "\n") .. "\n") or ""
    helpers.write_file("toMC.dat", payload)
end)

remote.add_interface("transferBridge", {
    setExportBudget = function(max_fluid_units, max_energy_joules)
        storage.bridge_fluid_export_cap = max_fluid_units
        storage.bridge_energy_export_cap = max_energy_joules
    end
})

remote.add_interface("receiveItems", {
    inputItems = function(item_name, count)
        local stack = {name = item_name, count = count}
        for _, rec in pairs(storage.transferChests) do
            if rec.valid and rec.name == "receive-chest" then
                local inventory = rec.get_inventory(defines.inventory.chest)
                if inventory.can_insert(stack) then
                    return inventory.insert(stack)
                end
            end
        end
        return 0
    end
})

remote.add_interface("receiveTanks", {
    inputTanks = function(fluid_name, amount)
        if not fluid_name or type(fluid_name) ~= "string" then
            return 0
        end
        amount = amount or 0
        if amount <= 0 then
            return 0
        end
        for _, rec in pairs(storage.transferTanks) do
            if rec.valid and rec.name == "receive-tank" then
                local inserted = rec.insert_fluid({name = fluid_name, amount = amount})
                if inserted > 0 then
                    return inserted
                end
            end
        end
        return 0
    end
})

remote.add_interface("receiveAccumulators", {
    --- Single arg: joules. Legacy: (_, joules). Returns joules added, or 0.
    inputAccumulators = function(a, b)
        local joules
        if type(a) == "number" and (b == nil or type(b) ~= "number") then
            joules = a
        elseif type(b) == "number" then
            joules = b
        else
            return 0
        end
        if joules <= 0 then
            return 0
        end
        for _, rec in pairs(storage.transferAccumulators) do
            if rec.valid and rec.name == "receive-accumulator" then
                local cap = rec.electric_buffer_size
                if cap and cap > 0 then
                    local cur = rec.energy or 0
                    local space = cap - cur
                    if space > 0 then
                        local add = math.min(joules, space)
                        rec.energy = cur + add
                        return add
                    end
                end
            end
        end
        return 0
    end
})
