local _ENV = _ENV or getfenv()
local index_env_metatable = { __index = _ENV }
local function instantiate_value(t, into_obj)
    if type(t) == 'table' then
        if type(t[1]) == 'function' then
            return t[1](unpack(t, 2))
        else
            local copy = into_obj or {}
            for k, v in pairs(t) do
                if copy[k] == nil then
                    copy[k] = instantiate_value(v)
                end
            end
            return copy
        end
    else
        return t
    end
end

-- Prepare constructor calls
local function preprocess_tree(tree)
    -- TODO: load depended object trees
    for kp, node, parent in nested.iterate(tree, { include_kv = true, table_only = true, order = nested.POSTORDER }) do
        local in_env = _ENV[node[1]]
        if is_callable(in_env) then
            if nested.metadata(node)() == nil then
                node[1] = in_env
            else
                table.remove(node, 1)
                parent[kp[#kp]] = { in_env, node }
            end
        end
    end
end

local function load_tree(name)
    local tree, err = assert(nested.decode_file(name, nested.bool_number_filter))
    if not tree then return nil, err end
    preprocess_tree(tree)
    return function(obj)
        obj = obj or setmetatable({}, index_env_metatable)
        return setfenv(instantiate_value, obj)(tree, obj)
    end
end



return load_tree