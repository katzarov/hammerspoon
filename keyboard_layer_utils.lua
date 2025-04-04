local keycodes = require("hs.keycodes")

local M = {}

-- Replaces letters from user config with keycode for specific key. This makes the config language agnostic.
--- @param layer_remaps table - user config for layer remaps.
function M.replaceKeyLetterWithKeyCode(layer_remaps)
    local table = {}
    for k, v in pairs(layer_remaps) do
        local keyCode = keycodes.map[k]
        table[keyCode] = v
    end
    return table
end

-- Get remapped value for a keyevent. Or nil if there is no remap for this key event.
--- @return string | nil modKey Modifier key - likely shift, if any.
--- @return number | nil key key, if any.
function M.getReplacementValue(keyEvent, replacementKeyMap)
    local keyCode = keyEvent:getKeyCode()
    local replacement = replacementKeyMap[keyCode]

    if type(replacement) == "table" then
        return replacement.mod, replacement.key
    end

    return nil, replacement
end

-- Gets all the current modifiers of this key event.
-- Makes sure to not duplicate modifiers - we might need to add a mod for our remapped value but this mod may already be held down.
-- Makes sure to not include the trigger key.
--- @param keyEvent unknown
--- @param flagOfReplacementValue string | nil
--- @param triggerKeyToRemoveFromFlags string | nil
--- @return table flagsTable - array of strings
function M.getFlags(keyEvent, flagOfReplacementValue, triggerKeyToRemoveFromFlags)
    -- btw, primitive values are passed by value. and tables by refrence.. so it looks like its the same as JS.
    local flags = {}
    for k, v in pairs(keyEvent:getFlags()) do
        if v then
            if (triggerKeyToRemoveFromFlags and k == triggerKeyToRemoveFromFlags) then
                -- since this is our trigger key we dont actually mean to use its original function, thus we should not include it in our modifiers table.
                goto continue
            end

            table.insert(flags, k)

            if (flagOfReplacementValue == k) then
                flagOfReplacementValue = nil
            end

            ::continue::
        end
    end

    if flagOfReplacementValue then
        table.insert(flags, flagOfReplacementValue)
    end

    return flags
end

return M
