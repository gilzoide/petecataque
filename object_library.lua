local _ENV = _ENV or getfenv()

local ObjectLibrary = {}
ObjectLibrary.__index = ObjectLibrary

function ObjectLibrary.new()
    return setmetatable({
        loaded = {}
    }, ObjectLibrary)
end

function ObjectLibrary:register(name, constructor)
    self.loaded[name] = constructor
    _ENV[name] = constructor
end

function ObjectLibrary:load(name)
    if not self.loaded[name] then
        local filename = 'objects/' .. name:gsub('%.', '/') .. '.lua'
        local constructor = assert(loadfile(filename))
        self:register(name, function()
            local obj = setmetatable({}, { __index = _ENV })
            obj.self = obj
            return setfenv(constructor, obj)()
        end)
    end
    return self.loaded[name]
end

function ObjectLibrary:instance(name)
    return assert(self:load(name))()
end

return ObjectLibrary