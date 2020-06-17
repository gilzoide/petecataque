local _ENV = _ENV or getfenv()

local function load_tree(name)
    local tree, err = assert(nested.decode_file(name, nested.bool_number_filter, nested_function.new))
    if not tree then return nil, err end
    local constructor = function(obj_to_copy)
        local newobj = tree()
        if obj_to_copy then
            for k, v in pairs(obj_to_copy) do
                newobj[k] = v
            end
        end
        return newobj
    end
    _ENV[name:match('([^/]+)%.nested$') or name] = constructor
    return constructor
end

return load_tree