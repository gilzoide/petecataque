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
local index_env_metatable = { __index = _ENV }
local function script_loader(name)
    local filename = 'script/' .. name:gsub('%.', '/') .. '.lua'
    local script = assert(loadfile(filename))
    local mt = setmetatable({}, index_env_metatable)
    setfenv(script, mt)()
    local index_mt = { __index = mt }
    local constructor = function(obj)
        obj = setmetatable(obj or {}, index_mt)
        for i = 1, #mt do
            local value = mt[i]
            if value ~= nil then
                obj[#obj + 1] = copy(value)
            end
        end
        for k, v in nested.metadata(mt) do
            if obj[k] == nil and k ~= 'when' and type(v) ~= 'function' then
                obj[k] = copy(v)
            end
        end
        if obj.init then setfenv(obj.init, obj)() end
        return obj
    end
    _ENV[name] = constructor
    return constructor
end

return script_loader