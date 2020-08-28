local table_pool = {}

local function simple_table_constructor()
    return {}
end

function table_pool.new(constructor)
    return setmetatable({
        constructor = constructor or simple_table_constructor
    }, table_pool)
end

function table_pool:acquire()
    local obj = table.remove(self) or self.constructor()
    self[obj] = nil
    return obj
end

function table_pool:release(obj)
    table.clear(obj)
    if not self[obj] then
        table.insert(self, obj)
        self[obj] = #self
    end
end

table_pool.__index = {
    acquire = table_pool.acquire,
    release = table_pool.release,
}

-- A table pool of plain raw tables
-- WARNING: do not add metatables to them!
table_pool.raw = table_pool.new()

return table_pool
