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

local _ENV = _ENV or getfenv()
local function script_loader(name)
    local filename = 'script/' .. name:gsub('%.', '/') .. '.lua'
    local script = assert(loadfile(filename))
    local mt = {}
    local index_mt = {
        __index = function(t, index)
            local value = rawget(t, index)
            if value ~= nil then return value end
            value = rawget(mt, index)
            if type(value) == 'function' then
                return setfenv(value, t)
            end
            if value ~= nil then return value end
            return _ENV[index]
        end
    }
    local constructor = function(self, obj)
        obj = setmetatable(obj or {}, index_mt)
        for k, v in nested.metadata(mt) do
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