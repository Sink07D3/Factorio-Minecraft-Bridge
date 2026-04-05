--[[
  Entity, item, and recipe prototypes for the transfer-chest mod.
  Send = blue tint, receive = red tint (vanilla __base__ graphics where applicable).
  Recipe ingredient lists are placeholders — tune for your mod pack.
]]
local transfer_send_tint = {0.35, 0.55, 1, 1}
local transfer_receive_tint = {1, 0.35, 0.35, 1}
-- Tank world sprites (same RGB as transfer_*; alpha 1 avoids premult artifacts at edges)
local tank_send_tint = {0.35, 0.55, 1, 1}
local tank_receive_tint = {1, 0.35, 0.35, 1}

local icon_chest = "__base__/graphics/icons/iron-chest.png"
local icon_tank = "__base__/graphics/icons/storage-tank.png"
local icon_accumulator = "__base__/graphics/icons/accumulator.png"
local icon_size = 64

-- Full storage-tank prototype (pipes + fluid window) with tinted body; matches vanilla storage-tank.
local function transfer_storage_tank(name, icon_tint, body_tint)
    return {
        type = "storage-tank",
        name = name,
        icons = {
            {icon = icon_tank, icon_size = icon_size, tint = icon_tint}
        },
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = name},
        max_health = 500,
        corpse = "storage-tank-remnants",
        dying_explosion = "storage-tank-explosion",
        collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        fast_replaceable_group = "storage-tank",
        icon_draw_specification = {scale = 1.5, shift = {0, -0.3}},
        fluid_box = {
            volume = 25000,
            pipe_connections = {
                {direction = defines.direction.north, position = {-1, -1}},
                {direction = defines.direction.east, position = {1, 1}},
                {direction = defines.direction.south, position = {1, 1}},
                {direction = defines.direction.west, position = {-1, -1}}
            },
            hide_connection_info = true
        },
        two_direction_only = true,
        window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
        pictures = {
            picture = {
                sheets = {
                    {
                        filename = "__base__/graphics/entity/storage-tank/storage-tank.png",
                        priority = "extra-high",
                        frames = 2,
                        width = 219,
                        height = 235,
                        shift = util.by_pixel(-0.25, -1.25),
                        scale = 0.5,
                        tint = body_tint
                    },
                    {
                        filename = "__base__/graphics/entity/storage-tank/storage-tank-shadow.png",
                        priority = "extra-high",
                        frames = 2,
                        width = 291,
                        height = 153,
                        shift = util.by_pixel(29.75, 22.25),
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            },
            fluid_background = {
                filename = "__base__/graphics/entity/storage-tank/fluid-background.png",
                priority = "extra-high",
                width = 32,
                height = 15
            },
            window_background = {
                filename = "__base__/graphics/entity/storage-tank/window-background.png",
                priority = "extra-high",
                width = 34,
                height = 48,
                scale = 0.5
            },
            flow_sprite = {
                filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
                priority = "extra-high",
                width = 160,
                height = 20
            },
            gas_flow = {
                filename = "__base__/graphics/entity/pipe/steam.png",
                priority = "extra-high",
                line_length = 10,
                width = 48,
                height = 30,
                frame_count = 60,
                animation_speed = 0.25,
                scale = 0.5
            }
        },
        flow_length_in_ticks = 360,
        impact_category = "metal-large",
        open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
        close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
        working_sound = {
            sound = {filename = "__base__/sound/storage-tank.ogg", volume = 0.6, audible_distance_modifier = 0.5},
            match_volume_to_activity = true,
            max_sounds_per_prototype = 3
        },
        water_reflection = {
            pictures = {
                filename = "__base__/graphics/entity/storage-tank/storage-tank-reflection.png",
                priority = "extra-high",
                width = 24,
                height = 24,
                shift = util.by_pixel(5, 35),
                variation_count = 1,
                scale = 5
            },
            rotate = false,
            orientation_to_variation = false
        }
    }
end

-- Real electric accumulators (charge/discharge on the network); tinted like transfer send/receive.
local function transfer_accumulator(name, icon_tint, body_tint)
    return {
        type = "accumulator",
        name = name,
        icons = {
            {icon = icon_accumulator, icon_size = icon_size, tint = icon_tint}
        },
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = name},
        fast_replaceable_group = "accumulator",
        max_health = 150,
        corpse = "accumulator-remnants",
        collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
        selection_box = {{-1, -1}, {1, 1}},
        drawing_box_vertical_extension = 0.5,
        energy_source = {
            type = "electric",
            buffer_capacity = "5MJ",
            usage_priority = "tertiary",
            input_flow_limit = "300kW",
            output_flow_limit = "300kW"
        },
        chargable_graphics = {
            picture = {
                layers = {
                    {
                        filename = "__base__/graphics/entity/accumulator/accumulator.png",
                        priority = "high",
                        width = 130,
                        height = 189,
                        shift = util.by_pixel(0, -11),
                        scale = 0.5,
                        tint = body_tint
                    },
                    {
                        filename = "__base__/graphics/entity/accumulator/accumulator-shadow.png",
                        priority = "high",
                        width = 234,
                        height = 106,
                        shift = util.by_pixel(29, 6),
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        impact_category = "metal-large",
        open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
        close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65}
    }
end

data:extend({
    -- Send Chest (vanilla iron-chest graphics + send tint)
    {
        type = "container",
        name = "send-chest",
        icons = {
            {icon = icon_chest, icon_size = icon_size, tint = transfer_send_tint}
        },
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 1, result = "send-chest"},
        max_health = 200,
        corpse = "iron-chest-remnants",
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fast_replaceable_group = "container",
        inventory_size = 1,
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        picture =
        {
            layers =
            {
                {
                    filename = "__base__/graphics/entity/iron-chest/iron-chest.png",
                    priority = "extra-high",
                    width = 66,
                    height = 76,
                    shift = util.by_pixel(-0.5, -0.5),
                    scale = 0.5,
                    tint = transfer_send_tint
                },
                {
                    filename = "__base__/graphics/entity/iron-chest/iron-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 50,
                    shift = util.by_pixel(10.5, 6),
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    },
    {
        type = "item",
        name = "send-chest",
        icons = {
            {icon = icon_chest, icon_size = icon_size, tint = transfer_send_tint}
        },
        flags = {},
        subgroup = "storage",
        order = "a[items]-b[send-chest]",
        place_result = "send-chest",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "send-chest",
        icons = {
            {icon = icon_chest, icon_size = icon_size, tint = transfer_send_tint}
        },
        ingredients = {
            {type="item", name="wood", amount=2},
            {type="item", name="iron-plate", amount=2}
        },
        results = {{type="item", name="send-chest", amount=1}},
        energy_required = 0.25
    },
    -- Receive Chest
    {
        type = "container",
        name = "receive-chest",
        icons = {
            {icon = icon_chest, icon_size = icon_size, tint = transfer_receive_tint}
        },
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 1, result = "receive-chest"},
        max_health = 200,
        corpse = "iron-chest-remnants",
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fast_replaceable_group = "container",
        inventory_size = 50,
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        picture =
        {
            layers =
            {
                {
                    filename = "__base__/graphics/entity/iron-chest/iron-chest.png",
                    priority = "extra-high",
                    width = 66,
                    height = 76,
                    shift = util.by_pixel(-0.5, -0.5),
                    scale = 0.5,
                    tint = transfer_receive_tint
                },
                {
                    filename = "__base__/graphics/entity/iron-chest/iron-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 50,
                    shift = util.by_pixel(10.5, 6),
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    },
    {
        type = "item",
        name = "receive-chest",
        icons = {
            {icon = icon_chest, icon_size = icon_size, tint = transfer_receive_tint}
        },
        flags = {},
        subgroup = "storage",
        order = "a[items]-b[receive-chest]",
        place_result = "receive-chest",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "receive-chest",
        icons = {
            {icon = icon_chest, icon_size = icon_size, tint = transfer_receive_tint}
        },
        ingredients = {
            {type="item", name="wood", amount=2},
            {type="item", name="iron-plate", amount=2}
        },
        results = {{type="item", name="receive-chest", amount=1}},
        energy_required = 0.25
    },


-- Send Tank (storage-tank: real fluid box + pipe connections; tinted like transfer send)
transfer_storage_tank("send-tank", transfer_send_tint, tank_send_tint),
{
    type = "item",
    name = "send-tank",
    icons = {
        {icon = icon_tank, icon_size = icon_size, tint = transfer_send_tint}
    },
    flags = {},
    subgroup = "storage",
    order = "a[items]-b[send-tank]",
    place_result = "send-tank",
    stack_size = 50
},
{
    type = "recipe",
    name = "send-tank",
    icons = {
        {icon = icon_tank, icon_size = icon_size, tint = transfer_send_tint}
    },
        ingredients = {
            {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="send-tank", amount=1}},
    energy_required = 0.25
},
-- Receive Tank
transfer_storage_tank("receive-tank", transfer_receive_tint, tank_receive_tint),
{
    type = "item",
    name = "receive-tank",
    icons = {
        {icon = icon_tank, icon_size = icon_size, tint = transfer_receive_tint}
    },
    flags = {},
    subgroup = "storage",
    order = "a[items]-b[receive-tank]",
    place_result = "receive-tank",
    stack_size = 50
},
{
    type = "recipe",
    name = "receive-tank",
    icons = {
        {icon = icon_tank, icon_size = icon_size, tint = transfer_receive_tint}
    },
        ingredients = {
            {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="receive-tank", amount=1}},
    energy_required = 0.25
},
-- Send Accumulator (real accumulator: 5 MJ buffer, ties to electric network)
transfer_accumulator("send-accumulator", transfer_send_tint, transfer_send_tint),
{
    type = "item",
    name = "send-accumulator",
    icons = {
        {icon = icon_accumulator, icon_size = icon_size, tint = transfer_send_tint}
    },
    flags = {},
    subgroup = "storage",
    order = "a[items]-b[send-accumulator]",
    place_result = "send-accumulator",
    stack_size = 50
},
{
    type = "recipe",
    name = "send-accumulator",
    icons = {
        {icon = icon_accumulator, icon_size = icon_size, tint = transfer_send_tint}
    },
        ingredients = {
            {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="send-accumulator", amount=1}},
    energy_required = 0.25
},
-- Receive Accumulator
transfer_accumulator("receive-accumulator", transfer_receive_tint, transfer_receive_tint),
{
    type = "item",
    name = "receive-accumulator",
    icons = {
        {icon = icon_accumulator, icon_size = icon_size, tint = transfer_receive_tint}
    },
    flags = {},
    subgroup = "storage",
    order = "a[items]-b[receive-accumulator]",
    place_result = "receive-accumulator",
    stack_size = 50
},
{
    type = "recipe",
    name = "receive-accumulator",
    icons = {
        {icon = icon_accumulator, icon_size = icon_size, tint = transfer_receive_tint}
    },
        ingredients = {
            {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="receive-accumulator", amount=1}},
    energy_required = 0.25
}
})