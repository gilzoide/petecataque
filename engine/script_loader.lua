local function copy(value)
    if type(value) == 'table' then
        local newvalue = {}
        for k, v in pairs(value) do
            newvalue[k] = copy(v)
        end
        return newvalue
    else
        return value
    end
end

local function script_loader(name)
    local script = assert(love.filesystem.load('script/' .. name:gsub('%.', '/') .. '.lua'))
    local mt = {}
    local index_mt = {
        __index = function(t, index)
            if index == 'self' then return t end
            value = rawget(mt, index)
            if type(value) == 'function' then
                return setfenv(value, t)
            end
            if value ~= nil then return value
            else return _ENV[index]
            end
        end
    }
    local constructor = function(self, obj)
        obj = setmetatable(obj or {}, index_mt)
        obj[0] = name
        for k, v in nested.kpairs(mt) do
            if obj[k] == nil and k ~= 'when' and type(v) ~= 'function' then
                obj[k] = copy(v)
            end
        end
        if obj.init then setfenv(obj.init, obj)() end
        return obj
    end
    setmetatable(mt, {__index = _ENV, __call = constructor})
    setfenv(script, mt)()
    _ENV[name] = mt
    return mt
end

return script_loader
