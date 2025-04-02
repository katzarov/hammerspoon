local eventtap = require("hs.eventtap")
local event = eventtap.event

local config = {}

config.keyboard = {
    -- always active remapping. we use it to shift z-b keys to `-v and then map b to `
    permanent_remap = {},
    -- needs to be a flag like caps lock or fn, or cmd, shift, alt etc. in Mac OS we have also switched caps lock with fn. So we press the phyisical caps lock key.
    layer_trigger_key = event.rawFlagMasks.secondaryFn,
    -- immediately activated upon pressing the trigger key. Upon trigger key release layer is deactivated.
    -- maybe do arrows keys vi style { h = "left", j = "down", k = "up", l = "right" }
    layer_remaps = { j = "left", k = "down", i = "up", l = "right", t = { mod = "shift", key = "9" }, y = { mod = "shift", key = "0" }, g = { mod = "shift", key = "[" }, h = { mod = "shift", key = "]" }, b = "[", n = "]" },
}

config.logging = true

-- if config.logging then
--     print("\n")
--     print("Config: \n")
--     table.print(config.keyboard.layer_remaps)
--     print("\n")
-- end

return config
