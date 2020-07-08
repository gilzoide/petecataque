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
    if not literal then return log.warnassert(nil, 'Expression literal is falsey') end
    local expr = { 'Expression', literal }
    local callable
    if type(literal) == 'function' then
        callable = function(mt, ...) return literal(...) end
    elseif type(literal) == 'string' then
        callable = assert(loadstring_with_env('return ' .. literal, expr))
    else
        callable = function(mt, ...)
            return nested_function.evaluate(literal, mt, ...)
        end
    end
    local mt = {
        __index = create_index_first_of(index_chain),
        __call = callable,
    }
    return setmetatable(expr, mt)
end

function Expression.call(literal, index_chain, ...)
    local expr = Expression.new(literal, index_chain)
    return expr and expr(...)
end

return Expression