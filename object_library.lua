local ObjectLibrary = {}
ObjectLibrary.__index = ObjectLibrary

function ObjectLibrary.new()
    return setmetatable({
        loaded = {}
    }, ObjectLibrary)
end

function ObjectLibrary:load(name)
    if not self.loaded[name] then
        local filename = 'objects/' .. name:gsub('%.', '/') .. '.lua'
        self.loaded[name] = assert(loadfile(filename))
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