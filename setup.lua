-- Might be better to make a Metatable instead of doing this. But I am fine with this for now. This adds the methods on the global table object. But you cannot actually call these methods on a table instance - this is where i can use metatables instead.

function table.find(t, value)
    for i = 1, #t do -- t is for table. indexing in Lua starts from 1. # operator gives you the length
        if t[i] == value then
            return i
        end
    end
    return nil
end

function table.print(t, prefix)
    for key, value in pairs(t) do
        if prefix then
            print(prefix, key, value)
        else
            print(key, value)
        end
    end
end

KEYBOARD_LAYER_TRIGGER_KEY_TYPE = {
    MODIFIER = 0,
    CHARACTER = 1
}
