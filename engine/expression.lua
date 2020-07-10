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

local loadstring = loadstring or load
local nested_function_evaluate = nested_function.evaluate

function Expression.is_expression(v)
    return type(v) == 'table' and v[1] == 'Expression'
end

function Expression.template(literal, no_return)
    if not literal then return log.warnassert(nil, 'Expression literal is falsey')
    elseif type(literal) == 'function' then return literal
    end

    local expr = { 'Expression', literal }
    if type(literal) == 'string' then
        if not no_return then
            literal = 'return ' .. literal
        end
        local chunk = assert(loadstring(literal))
        expr.callable = function(expr, ...)
            return setfenv(chunk, expr)()
        end
    else
        expr.callable = function(expr, ...)
            return nested_function_evaluate(expr[2], expr, ...)
        end
    end

    return expr
end

function Expression.instantiate(template, index_chain)
    if type(template) == 'function' then return template end
    assertf(Expression.is_expression(template), "FIXME invalid expression template %q", nested.encode(template))

    local expr = { 'Expression', template[2] }
    local mt = {
        __index = create_index_first_of(index_chain),
        __call = template.callable,
    }
    return setmetatable(expr, mt)
end

function Expression.new(literal, index_chain)
    local template = Expression.template(literal)
    return Expression.instantiate(template, index_chain)
end

function Expression.call(template, index_chain, ...)
    local expr = Expression.instantiate(template, index_chain)
    return expr and expr(...)
end

return Expression