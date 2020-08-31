local table_stack = {}

function table_stack.new()
    return setmetatable({ n = 0 }, table_stack)
end

function table_stack:push(...)
    self.n = self.n + 1
    local entry = self[self.n]
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

local methods = {
    push = table_stack.push,
    peek = table_stack.peek,
    pop = table_stack.pop,
    clear = table_stack.clear,
}
local weak_mt = { __mt = 'kv' }
function table_stack:__index(index)
    if methods[index] then return methods[index] end
    local new_table = setmetatable({}, weak_mt)
    rawset(self, index, new_table)
    return new_table
end

return table_stack
