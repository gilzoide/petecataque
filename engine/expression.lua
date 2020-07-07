local Expression = {}

local loadstring_with_env
if setfenv and loadstring then
    loadstring_with_env = function(body, env)
        local chunk, err = loadstring(body)
        if not chunk then return nil, err end
        return setfenv(chunk, env)
    end
else
    loadstring_with_env = function(body, env)
        return load(body, nil, 't', env)
    end
end

function Expression.new(literal, index_chain)
    local expr = { 'Expression', literal }
    local mt = {
        __index = function(t, index)
            return index_first_of(index, index_chain)
        end,
        __call = assert(loadstring_with_env('return ' .. literal, expr)),
    }
    return setmetatable(expr, mt)
end

return Expression