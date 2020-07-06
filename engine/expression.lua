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

function Expression.new(literal, relative_to)
    local callable = assert(loadstring_with_env('return ' .. literal, relative_to))
    return setmetatable({
        'Expression',
        literal,
    }, { __call = callable })
end

return Expression