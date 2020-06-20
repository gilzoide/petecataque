local Input = {}
Input.__index = Input

local events = {
    'mousemoved', 'mousepressed', 'mousereleased', 'wheelmoved',
    'keypressed', 'keyreleased'
}

function Input.new()
    local input = setmetatable({}, Input)
    input:reset()
    return input
end

function Input:reset()
    for i = 1, #events do
        self[events[i]] = {}
    end
end

return Input