local config = require("config")

if config.keyboard.layer_trigger_key_type == KEYBOARD_LAYER_TRIGGER_KEY_TYPE.CHARACTER then
    require("keyboard_layer_trigger_character")
elseif config.keyboard.layer_trigger_key_type == KEYBOARD_LAYER_TRIGGER_KEY_TYPE.MODIFIER then
    require("keyboard_layer_trigger_modifier")
else
    error('Not implemented')
end
