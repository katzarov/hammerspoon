local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")
local config = require("config")

local event = eventtap.event
local keyboardConfig, logging = config.keyboard, config.logging

-- that makes the layers keys language agnostic
local replaceKeyLetterWithKeyCode = function(t)
    local table = {}
    for k, v in pairs(t) do
        local keyCode = keycodes.map[k]
        table[keyCode] = v
    end
    return table
end

local layerReplacements = replaceKeyLetterWithKeyCode(keyboardConfig.layer_remaps)

--- @return string|nil modKey Modifier key - likely shift, if any.
--- @return number|nil key key, if any.
local getReplacementValue = function(keyEvent, replacementKeyMap)
    local keyCode = keyEvent:getKeyCode()
    local replacement = replacementKeyMap[keyCode]

    if type(replacement) == "table" then
        return replacement.mod, replacement.key
    end

    return nil, replacement
end

--- @param keyEvent unknown
--- @param flagOfReplacementValue string|nil
--- @return table flagsTable - array of strings
local getFlags = function(keyEvent, flagOfReplacementValue)
    -- btw, primitive values are passed by value. and tables by refrence.. so it looks like its the same as JS.
    local flags = {}
    for k, v in pairs(keyEvent:getFlags()) do
        if v then
            if (k == "fn") then
                -- since this is our trigger key we dont actually mean to use its original function.
                -- Thankfully, so far I have used this key only for switching languages, so for me its fine to throw it away.
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

-- make this for flag keys like fn or tabs lock
-- TODO make another handler for keys like spacebar or something else i try to use a trigger.
-- key handling function
local keyEventHandler = function(e)
    local flag, replacement = getReplacementValue(e, layerReplacements)

    -- btw, in lua, the only thing that is falsey is false and nil.
    if not replacement then
        -- do nothing to the event, just pass it along
        -- so cases like fn + the function keys... or fn + f can totaly work since we dont provide a map for function keys or the f key - at least for now.
        return false
    end

    -- replacement has a value, so one of our layer keys was pressed.
    -- we need to duplicate the event, keeping all traditional modifiers, but with our layer key instead, (and possible that we have added a modifier)

    local flags = getFlags(e, flag)
    local isDown = e:getType() == event.types.keyDown
    local replacementEvent = event.newKeyEvent(flags, replacement, isDown)

    if isDown then
        -- if a key is held down, it actually sends a second down event, but with
        -- the autorepeat property set, so duplicate that as well if this is a
        -- key-down event:
        replacementEvent:setProperty(event.properties.keyboardEventAutorepeat,
            e:getProperty(event.properties.keyboardEventAutorepeat))
    end

    if logging then
        print('remapped key event: ')
        table.print(flags, 'mods: ')
        print('key:', replacement, '\n')
    end

    -- throw out the original event and replace it with ours
    return true, { replacementEvent }
end

-- get initial trigger key state, (btw, this script was copied from ... where they used caps lock)
local flagState = (eventtap.checkKeyboardModifiers(true)._raw & keyboardConfig.layer_trigger_key) ~= 0

-- set up, but don't start, keyup/keydown eventtap
local keyListener = eventtap.new({ event.types.keyDown, event.types.keyUp }, keyEventHandler)

-- this is the eventtap function that checks for the modifier key change
local flagsChangedHandler = function(e)
    -- this is so we can use it to set initial state when started up
    local state
    if type(e) == "boolean" then
        state = e
        flagState = not flagState
    else
        state = (e:rawFlags() & keyboardConfig.layer_trigger_key) ~= 0
    end

    if state and not flagState then
        flagState = true
        keyListener:start()
    elseif not state and flagState then
        flagState = false
        keyListener:stop()
    end
end

-- set initial state
flagsChangedHandler(flagState)

-- start watching flags. flags are modifier keys like cmd, shift, caps lock, fn.
-- also we keep this listener as a global var cause i don't know if it will get GC-ed otherwise since we don't reference it anywhere
flagsListener = eventtap.new({ event.types.flagsChanged }, flagsChangedHandler):start()
