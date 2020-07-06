local Graphics = {
    'Graphics',
    SKIP_CHILDREN = true,
}

function Graphics.call(name, ...)
    local operation = log.warnassert(love.graphics[name], "Invalid graphics operation %q", name)
    if operation then operation(...) end
end

function Graphics:draw()
    for kp, t in nested.iterate(self, { include_kv = true, skip_root = true, table_only = true }) do
        local key = kp[#kp]
        if type(key) == 'number' then
            local first = t[1]
            if type(first) == 'string' then
                Graphics.call(unpack(t))
            end
        else
            Graphics.call(key, unpack(t))
        end
    end
end

return Graphics