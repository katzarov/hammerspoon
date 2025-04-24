local eventtap = require("hs.eventtap")
local event = eventtap.event

local config = {}

config.keyboard = {
    -- always active remapping. we use it to shift z-b keys to `-v and then map b to `
    permanent_remap = {},
    -- needs to be a modifier key like caps lock, fn, cmd, shift or alt etc. in Mac OS we have also switched caps lock with fn. So we press the phyisical caps lock key.
    layer_trigger_key_type = KEYBOARD_LAYER_TRIGGER_KEY_TYPE.CHARACTER,
    -- https://www.hammerspoon.org/docs/hs.eventtap.event.html#rawFlagMasks
    layer_trigger_key_raw = event.rawFlagMasks.secondaryFn,
    layer_trigger_key = "space",
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
