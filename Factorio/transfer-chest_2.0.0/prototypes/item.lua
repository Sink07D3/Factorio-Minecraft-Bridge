-- Send = blue, receive = red. Vanilla __base__ sprites + tint on items, entities, recipes.
local transfer_send_tint = {0.35, 0.55, 1, 1}
local transfer_receive_tint = {1, 0.35, 0.35, 1}
-- Tank world sprites (same RGB as transfer_*; alpha 1 avoids premult artifacts at edges)
local tank_send_tint = {0.35, 0.55, 1, 1}
local tank_receive_tint = {1, 0.35, 0.35, 1}

local icon_chest = "__base__/graphics/icons/iron-chest.png"
local icon_tank = "__base__/graphics/icons/storage-tank.png"
local icon_accumulator = "__base__/graphics/icons/accumulator.png"
local icon_size = 64

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
            --TODO: Adjust ingredients 
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
            --TODO: Adjust ingredients 
            {type="item", name="wood", amount=2},
            {type="item", name="iron-plate", amount=2}
        },
        results = {{type="item", name="receive-chest", amount=1}},
        energy_required = 0.25
    },


-- Send Tank (vanilla storage-tank graphics + send tint)
{
    type = "container",
    name = "send-tank",
    icons = {
        {icon = icon_tank, icon_size = icon_size, tint = transfer_send_tint}
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "send-tank"},
    max_health = 500,
    corpse = "storage-tank-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 2}},
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    icon_draw_specification = {scale = 1.5, shift = {0, -0.3}},
    drawing_box_vertical_extension = 1.5,
    picture =
    {
        layers =
        {
            {
                filename = "__base__/graphics/entity/storage-tank/storage-tank.png",
                priority = "extra-high",
                width = 219,
                height = 235,
                shift = util.by_pixel(-0.25, -1.25),
                scale = 0.5,
                tint = tank_send_tint,
                flags = {"no-crop"}
            },
            {
                filename = "__base__/graphics/entity/storage-tank/storage-tank-shadow.png",
                priority = "extra-high",
                width = 291,
                height = 153,
                shift = util.by_pixel(29.75, 22.25),
                scale = 0.5,
                draw_as_shadow = true,
                flags = {"no-crop"}
            }
        }
    }
},
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
        --TODO: Adjust ingredients 
        {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="send-tank", amount=1}},
    energy_required = 0.25
},
-- Receive Tank
{
    type = "container",
    name = "receive-tank",
    icons = {
        {icon = icon_tank, icon_size = icon_size, tint = transfer_receive_tint}
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "receive-tank"},
    max_health = 500,
    corpse = "storage-tank-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 2}},
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    icon_draw_specification = {scale = 1.5, shift = {0, -0.3}},
    drawing_box_vertical_extension = 1.5,
    picture =
    {
        layers =
        {
            {
                filename = "__base__/graphics/entity/storage-tank/storage-tank.png",
                priority = "extra-high",
                width = 219,
                height = 235,
                shift = util.by_pixel(-0.25, -1.25),
                scale = 0.5,
                tint = tank_receive_tint,
                flags = {"no-crop"}
            },
            {
                filename = "__base__/graphics/entity/storage-tank/storage-tank-shadow.png",
                priority = "extra-high",
                width = 291,
                height = 153,
                shift = util.by_pixel(29.75, 22.25),
                scale = 0.5,
                draw_as_shadow = true,
                flags = {"no-crop"}
            }
        }
    }
},
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
        --TODO: Adjust ingredients 
        {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="receive-tank", amount=1}},
    energy_required = 0.25
},
-- Send Accumulator (vanilla accumulator graphics + send tint)
{
    type = "container",
    name = "send-accumulator",
    icons = {
        {icon = icon_accumulator, icon_size = icon_size, tint = transfer_send_tint}
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "send-accumulator"},
    max_health = 150,
    corpse = "accumulator-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{-1, -1}, {1, 1}},
    drawing_box_vertical_extension = 0.5,
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
        layers =
        {
            {
                filename = "__base__/graphics/entity/accumulator/accumulator.png",
                priority = "high",
                width = 130,
                height = 189,
                shift = util.by_pixel(0, -11),
                scale = 0.5,
                tint = transfer_send_tint
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
        --TODO: Adjust ingredients 
        {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="send-accumulator", amount=1}},
    energy_required = 0.25
},
-- Receive Accumulator
{
    type = "container",
    name = "receive-accumulator",
    icons = {
        {icon = icon_accumulator, icon_size = icon_size, tint = transfer_receive_tint}
    },
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "receive-accumulator"},
    max_health = 150,
    corpse = "accumulator-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{-1, -1}, {1, 1}},
    drawing_box_vertical_extension = 0.5,
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
        layers =
        {
            {
                filename = "__base__/graphics/entity/accumulator/accumulator.png",
                priority = "high",
                width = 130,
                height = 189,
                shift = util.by_pixel(0, -11),
                scale = 0.5,
                tint = transfer_receive_tint
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
        --TODO: Adjust ingredients 
        {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="receive-accumulator", amount=1}},
    energy_required = 0.25
}
})