-- Settings stage runs before data/control; see https://wiki.factorio.com/Tutorial:Mod_settings
data:extend({
    {
        type = "bool-setting",
        name = "transfer-chest-legacy-file-export",
        setting_type = "runtime-global",
        default_value = false,
        order = "a"
    }
})
