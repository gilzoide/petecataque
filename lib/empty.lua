local Empty = {}

local function dummy()
    return Empty
end

Empty.__index = dummy
Empty.__newindex = dummy
Empty.__call = dummy

return setmetatable(Empty, Empty)