local Empty = {}

function Empty.__index(table, index)
    local value = rawget(table, index)
    if value == nil then value = Empty end
    return value
end

local function dummy()
    return Empty
end

return setmetatable(Empty, { __index = Empty.__index, __newindex = dummy, __call = dummy })