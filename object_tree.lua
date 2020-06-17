local _ENV = _ENV or getfenv()
local index_env_metatable = { __index = _ENV }

local function load_tree(name)
    local tree, err = assert(nested.decode_file(name, nested.bool_number_filter, nested_function.new))
    if not tree then return nil, err end
    return function(obj)
        obj = obj or setmetatable({}, index_env_metatable)
        return setfenv(nested_function.evaluate, obj)(tree, obj)
    end
end

return load_tree