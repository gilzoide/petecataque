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
    local callable
    if type(literal) == 'table' then
        callable = function(mt)
            return nested_function.evaluate(literal, mt)
        end
    else
        callable = assert(loadstring_with_env('return ' .. literal, expr))
    end
    local mt = {
        __index = create_index_first_of(index_chain),
        __call = callable,
    }
    return setmetatable(expr, mt)
end

return Expression