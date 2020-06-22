local Setqueue = {}
Setqueue.__index = Setqueue

function Setqueue.new()
    return setmetatable({}, Setqueue)
end

function Setqueue:queue(root, keypath, value)
    self[#self + 1] = { root, keypath, value }
end

function Setqueue:update()
    for i = 1, #self do
        nested.set(unpack(self[i]))
        self[i] = nil
    end
end

return Setqueue
