local Graphics = {
    'Graphics',
    SKIP_CHILDREN = true,
}

function Graphics:init()
    local root
    if self.root ~= self then root = self.root end
    for kp, v in nested.iterate(self) do
        if type(v) == 'string' and v:sub(1, 1) == '$' then
            local expr = Expression.new(v:sub(2), self, root)
            set(self, kp, expr)
        end
    end
end

function Graphics.call(name, ...)
    local operation = log.warnassert(love.graphics[name], "Invalid graphics operation %q", name)
    if operation then
        local args = {}
        for i = 1, select('#', ...) do
            local arg = select(i, ...)
            local callable, result = pcall(arg)
            if callable then arg = result end
            args[i] = arg
        end
        operation(unpack(args))
    end
end

function Graphics:draw()
    for kp, t in nested.iterate(self, { include_kv = true, skip_root = true, table_only = true }) do
        local key = kp[#kp]
        if type(key) == 'number' then
            local first = t[1]
            if type(first) == 'string' and first ~= 'Expression' then
                Graphics.call(unpack(t))
            end
        else
            Graphics.call(key, unpack(t))
        end
    end
end

return Graphics