local _ENV = _ENV or getfenv()

local function object_filename(name)
    return 'objects/' .. name:gsub('%.', '/') .. '.lua'
end

local builtin_objects = {
    Transform = love and love.math.newTransform or true,
}

local ObjectLibrary = {}
ObjectLibrary.__index = ObjectLibrary

ObjectLibrary.builtin_objects = builtin_objects

function ObjectLibrary.new()
    return setmetatable({
        loaded = {}
    }, ObjectLibrary)
end

function ObjectLibrary:register_love()
    for name, constructor in pairs(builtin_objects) do
        self:register(name, constructor)
    end
    return self
end

function ObjectLibrary:register(name, constructor)
    self.loaded[name] = constructor
    _ENV[name] = constructor
end

function ObjectLibrary:load(name)
    if not self.loaded[name] then
        local constructor = assert(loadfile(object_filename(name)))
        self:register(name, function()
            local obj = setmetatable({}, { __index = _ENV })
            obj.self = obj
            return setfenv(constructor, obj)()
        end)
    end
    return self.loaded[name]
end

return ObjectLibrary