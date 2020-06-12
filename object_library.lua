local nested_game_object = require 'nested_game_object'

local ObjectLibrary = {}
ObjectLibrary.__index = ObjectLibrary

function ObjectLibrary.new()
    return setmetatable({
        loaded = {}
    }, ObjectLibrary)
end

function ObjectLibrary:load(name)
    if not self.loaded[name] then
        local basename = 'objects/' .. name:gsub('%.', '/')
        local luafile, nestedfile = basename .. '.lua', basename .. '.nested'
        if luafile then 
            self.loaded[name] = assert(loadfile(luafile))
        elseif nestedfile then
            self.loaded[name] = assert(nested_game_object.loadfile(nestedfile))
        else
            errorf('Unable to load object %q', name)
        end
    end
    return self.loaded[name]
end

function ObjectLibrary:instance(name)
    local constructor = assert(self:load(name))
    local obj = setmetatable({}, {
        __index = _ENV or getfenv()
    })
    obj.self = obj
    return setfenv(constructor, obj)()
end

return ObjectLibrary