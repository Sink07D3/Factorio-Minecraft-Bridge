data:extend({
    -- Send Chest
    {
        type = "container",
        name = "send-chest",
        icon = "__transfer-chest__/graphics/send-chest-icon.png",
        icon_size = 32,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 1, result = "send-chest"},
        max_health = 100,
        corpse = "small-remnants",
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fast_replaceable_group = "container",
        inventory_size = 1,
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        picture =
        {
            filename = "__transfer-chest__/graphics/send-chest.png",
            priority = "extra-high",
            width = 48,
            height = 34,
            shift = {0.1875, 0}
        }
    },
    {
        type = "item",
        name = "send-chest",
        icon = "__transfer-chest__/graphics/send-chest-icon.png",
        icon_size = 32,
        flags = {},
        subgroup = "storage",
        order = "a[items]-b[send-chest]",
        place_result = "send-chest",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "send-chest",
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
        icon = "__transfer-chest__/graphics/receive-chest-icon.png",
        icon_size = 32,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 1, result = "receive-chest"},
        max_health = 100,
        corpse = "small-remnants",
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
        collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fast_replaceable_group = "container",
        inventory_size = 50,
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        picture =
        {
            filename = "__transfer-chest__/graphics/receive-chest.png",
            priority = "extra-high",
            width = 48,
            height = 34,
            shift = {0.1875, 0}
        }
    },
    {
        type = "item",
        name = "receive-chest",
        icon = "__transfer-chest__/graphics/receive-chest-icon.png",
        icon_size = 32,
        flags = {},
        subgroup = "storage",
        order = "a[items]-b[receive-chest]",
        place_result = "receive-chest",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "receive-chest",
        ingredients = {
            --TODO: Adjust ingredients 
            {type="item", name="wood", amount=2},
            {type="item", name="iron-plate", amount=2}
        },
        results = {{type="item", name="receive-chest", amount=1}},
        energy_required = 0.25
    }


-- Send Tank
{
    type = "container",
    name = "send-tank",
    icon = "__transfer-chest__/graphics/send-tank-icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "send-tank"},
    max_health = 100,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
        filename = "__transfer-chest__/graphics/send-tank.png",
        priority = "extra-high",
        width = 48,
        height = 34,
        shift = {0.1875, 0}
    }
},
{
    type = "item",
    name = "send-tank",
    icon = "__transfer-chest__/graphics/send-tank-icon.png",    
    icon_size = 32,
    flags = {},
    subgroup = "storage",
    order = "a[items]-b[send-tank]",
    place_result = "send-tank",
    stack_size = 50
},
{
    type = "recipe",
    name = "send-tank",
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
    icon = "__transfer-chest__/graphics/receive-tank-icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "receive-tank"},
    max_health = 100,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
        filename = "__transfer-chest__/graphics/receive-tank.png",
        priority = "extra-high",
        width = 48,
        height = 34,    
-- Send Accumulator
{
    type = "container",
    name = "send-accumulator",
    icon = "__transfer-chest__/graphics/send-accumulator-icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "send-accumulator"},
    max_health = 100,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
        filename = "__transfer-chest__/graphics/send-accumulator.png",
        priority = "extra-high",
        width = 48,
        height = 34,
        shift = {0.1875, 0}
    }
},
{
    type = "item",
    name = "send-accumulator",
    icon = "__transfer-chest__/graphics/send-accumulator-icon.png",
    icon_size = 32,
    flags = {},
    subgroup = "storage",
    order = "a[items]-b[send-accumulator]",
    place_result = "send-accumulator",
    stack_size = 50
},
{
-- Receive Accumulator
{
    type = "container",
    name = "receive-accumulator",
    icon = "__transfer-chest__/graphics/receive-accumulator-icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "receive-accumulator"},
    max_health = 100,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 1,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
        filename = "__transfer-chest__/graphics/receive-accumulator.png",
        priority = "extra-high",
        width = 48,
        height = 34,
        shift = {0.1875, 0}
    }
},
{
    type = "item",
    name = "receive-accumulator",
    icon = "__transfer-chest__/graphics/receive-accumulator-icon.png",
    icon_size = 32,
    flags = {},
    subgroup = "storage",
    order = "a[items]-b[receive-accumulator]",
    place_result = "receive-accumulator",
    stack_size = 50
},
{
    type = "recipe",
    name = "receive-accumulator",
    ingredients = {
        --TODO: Adjust ingredients 
        {type="item", name="wood", amount=2},
        {type="item", name="iron-plate", amount=2}
    },
    results = {{type="item", name="receive-accumulator", amount=1}},
    energy_required = 0.25
}
})