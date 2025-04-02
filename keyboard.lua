local eventtap = require("hs.eventtap")
local event = eventtap.event

local config = require("config")
local keyboardConfig = config.keyboard
local logging = config.logging

local replaceKeyLetterWithKeyCode = function(t)
    local table = {}
    for k, v in pairs(t) do
        local keyCode = hs.keycodes.map[k]
        table[keyCode] = v
    end
    return table
end

local replacements = replaceKeyLetterWithKeyCode(keyboardConfig.layer_remaps)

-- returns a mod key if any and the remapped key
local getReplacementValue = function(keyEvent, replacementKeyMap)
    local keyCode = keyEvent:getKeyCode()
    local replacement = replacementKeyMap[keyCode]

    if type(replacement) == "table" then
        return replacement.mod, replacement.key
    end

    return nil, replacement
end

-- get initial trigger key state, this script was copied from TODO where they used caps lock
local clFlagState = (eventtap.checkKeyboardModifiers(true)._raw & keyboardConfig.layer_trigger_key) ~= 0

-- make this for flag keys like fn or tabs lock
-- TODO make another handler for keys like spacebar or something else i try to use a trigger.
-- key handling function
local keyHandler = function(e)
    local flag, replacement = getReplacementValue(e, replacements)

    -- if replacement has a value, then one of our keys was pressed
    if replacement then
        -- duplicate the event, keeping all traditional modifiers, but with our (arrow) key instead
        local isDown = e:getType() == event.types.keyDown
        local flags = {}

        for k, v in pairs(e:getFlags()) do
            if v then
                if (k == "fn") then
                    -- since this is our trigger key we dont actually mean to use its original funciton. Thankfully, so far I have used this key only for switching languages, so for me its fine to throw it away.
                    goto continue
                end

                table.insert(flags, k)

                if (flag == k) then
                    -- if we have already setting up the required flag for this event - likely a shift, then lets not do it again.
                    flag = nil
                end

                ::continue::
            end
        end

        if flag then
            table.insert(flags, flag)
        end

        local replacementEvent = event.newKeyEvent(flags, replacement, isDown)
        if isDown then
            -- if a key is held down, it actually sends a second down event, but with
            -- the autorepeat property set, so duplicate that as well if this is a
            -- key-down event:
            replacementEvent:setProperty(event.properties.keyboardEventAutorepeat,
                e:getProperty(event.properties.keyboardEventAutorepeat))
        end

        if logging then
            print('modified: ')
            table.print(flags, 'mods: ')
            print('key', replacement, '\n')
        end

        -- throw out the original event and replace it with ours
        return true, { replacementEvent }
    else
        -- otherwise, do nothing to the event, just pass it along
        -- so cases like fn + the function keys... or fn + f can totaly work since we dont provide a map for function keys or the f key - at least for now.
        return false
    end
end

-- set up, but don't start, keyup/keydown eventtap
local keyListener = eventtap.new({ event.types.keyDown, event.types.keyUp }, keyHandler)

-- this is the eventtap function that checks for the caps lock key change
local eventtapFn = function(e)
    -- this is so we can use it to set initial state when started up
    local state
    if type(e) == "boolean" then
        state = e
        clFlagState = not clFlagState
    else
        state = (e:rawFlags() & keyboardConfig.layer_trigger_key) ~= 0
    end

    if state and not clFlagState then
        clFlagState = true
        keyListener:start()
    elseif not state and clFlagState then
        clFlagState = false
        keyListener:stop()
    end
end

-- set initial state
eventtapFn(clFlagState)

-- start watching flags
tap = eventtap.new({ event.types.flagsChanged }, eventtapFn):start()
