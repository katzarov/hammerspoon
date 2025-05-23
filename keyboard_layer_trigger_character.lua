local keyboard_utils = require("keyboard_layer_utils")
local config = require("config")
local keyboardConfig, logging = config.keyboard, config.logging
--------------------------------------------------------------------------------
-- Single eventtap for Space-hold-to-Layer
--------------------------------------------------------------------------------

local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")
local event = eventtap.event

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local triggerKey = "space"
local holdDelay = 0.15 -- how long the user must hold space to activate “layer”

--------------------------------------------------------------------------------
-- State variables
--------------------------------------------------------------------------------

local spaceHeld = false
local spaceTimer = nil
local layerSoftActivated = false
local layerHardActivated = false
local blockedSpace = false

--------------------------------------------------------------------------------
-- Mapping i/j/k/l to arrow keys
--------------------------------------------------------------------------------


local layerReplacements = keyboard_utils.replaceKeyLetterWithKeyCode(keyboardConfig.layer_remaps)


--------------------------------------------------------------------------------
-- Activate/Deactivate the “space” layer
--------------------------------------------------------------------------------

local function activateLayer()
    layerSoftActivated = true
    print("Layer Activated")
end

local function deactivateLayer()
    layerSoftActivated = false
    layerHardActivated = false
    print("Layer Deactivated")
end

--------------------------------------------------------------------------------
-- The single eventtap callback
--------------------------------------------------------------------------------

local callback = function(e)
    -- Ignore events generated by Hammerspoon itself (prevents loops):
    if e:getProperty(event.properties.eventSourceUnixProcessID) ~= 0 then
        return false
    end

    local keyCode = e:getKeyCode()
    local isKeyDown = (e:getType() == event.types.keyDown)

    -- 1) If this event is for our trigger key (space):
    if keyCode == keycodes.map[triggerKey] then
        if isKeyDown then
            -- Space Down
            if not spaceHeld then
                spaceHeld = true
                spaceTimer = hs.timer.doAfter(holdDelay, function()
                    activateLayer()
                end)
            end
            -- Block space auto-repeat until we decide
            -- todo as needt to block charactes until we decicde casse pressing at samet time space + i produces an i with no space
            blockedSpace = true
            return true
        else
            -- Space Up
            if spaceTimer then
                spaceTimer:stop()
                spaceTimer = nil
            end

            if layerSoftActivated then
                if not layerHardActivated then
                    -- again record event and send taht, also need to refactor this sheisse
                    local flags = keyboard_utils.getFlags(e)
                    hs.eventtap.keyStroke(flags, triggerKey, 0)
                    print('send spxae')
                end

                -- If layer was active, turn it off
                deactivateLayer()
            elseif blockedSpace then
                -- If layer wasn’t active, send a normal space
                local flags = keyboard_utils.getFlags(e)
                hs.eventtap.keyStroke(flags, triggerKey, 0)
                blockedSpace = false
            end

            spaceHeld = false
            return true
        end

        -- 2) If the event is NOT space, but we’re in layer mode, check i/j/k/l => arrows
    elseif layerSoftActivated then
        layerHardActivated = true;
        local flag, replacement = keyboard_utils.getReplacementValue(e, layerReplacements)
        if replacement then
            -- Block the original event and post arrow key with same flags
            local flags = keyboard_utils.getFlags(e, flag, keyboardConfig.layer_trigger_key)
            local newEvent = event.newKeyEvent(flags, replacement, isKeyDown)
            newEvent:post()
            return true
        end
    end

    -- handle rolling
    -- need to fix - hold down space for long time and then press some letter !!!! TOOD
    if spaceTimer and spaceTimer:running() and blockedSpace and isKeyDown then
        -- if blockedSpace and isKeyDown then
        -- todo record original blocked event and send that!
        local newEvent = event.newKeyEvent(flags, 'space', isKeyDown)
        newEvent:post()
        local newEvent = event.newKeyEvent(flags, keyCode, isKeyDown)
        newEvent:post()
        blockedSpace = false
        spaceTimer:stop()
        print('handle rolling from char to space')
        return true
    end

    -- 3) If none of the above conditions matched, we do not interfere
    return false
end

--------------------------------------------------------------------------------
-- Create and start a single eventtap
--------------------------------------------------------------------------------

spaceLayerWatcher = eventtap.new({ event.types.keyDown, event.types.keyUp }, callback):start()

--------------------------------------------------------------------------------
-- That’s it!
--------------------------------------------------------------------------------

--TODO hande if no key was presssed while layer was active just send space again... and even handle repeating space if no layer has been pressed in some window say 1second !! yeah this will fix the feeling and it will be just fine

-- todo maybe if we havent pressed any keys for a while, then if we press the spacebar its more likely we want to trigger the second layer.

-- actually write some tests for the keypresses!!!
