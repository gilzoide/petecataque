local table_stack = {}

local weak_mt = { __mt = 'kv' }
function table_stack.new()
    return setmetatable({ n = 0 }, table_stack)
end

function table_stack:push(...)
    self.n = self.n + 1
    local entry = self[self.n]
    if not entry then
        entry = setmetatable({}, weak_mt)
        self[self.n] = entry
    end
    for i = 1, select('#', ...) do
        entry[i] = select(i, ...)
    end
    return entry
end

function table_stack:peek()
    return self[self.n]
end

function table_stack:pop()
    local prev = self[self.n]
    self.n = self.n - 1
    return prev
end

function table_stack:clear(n)
    self.n = n or 0
end

table_stack.__index = {
    push = table_stack.push,
    peek = table_stack.peek,
    pop = table_stack.pop,
    clear = table_stack.clear,
}

return table_stack
