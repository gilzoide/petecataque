local Graphics = {
    'Graphics',
    SKIP_CHILDREN = true,
}

local function safeunpack(v)
    if type(v) == 'table' then
        return unpack(v)
    elseif v ~= nil then
        return v
    end
    -- if v == nil, return no value
end

local function graphics_call(name, ...)
    local operation = log.warnassert(love.graphics[name], "Invalid graphics operation %q", name)
    if operation then operation(...) end
end

local function graphics_do(list)
    for kp, t in nested.iterate(list, { include_kv = true, skip_root = true, table_only = true }) do
        local key = kp[#kp]
        if type(key) == 'number' then
            local first = t[1]
            if type(first) == 'string' then
                graphics_call(unpack(t))
            end
        else
            graphics_call(key, unpack(t))
        end
    end
end

function Graphics:draw()
    graphics_do(self)
end

return Graphics