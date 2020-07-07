local Setqueue = {}
Setqueue.__index = Setqueue

function Setqueue.new()
    return setmetatable({
        this_frame = {},
        next_frame = {},
    }, Setqueue)
end

function Setqueue:queue(root, keypath, value)
    self.next_frame[#self.next_frame + 1] = { root, keypath, value }
end

function Setqueue:flip()
    self.next_frame, self.this_frame = self.this_frame, self.next_frame
end

function Setqueue:update(dt)
end

function Setqueue:frame_ended()
    for i = 1, #self.this_frame do
        set(unpack(self.this_frame[i]))
        self.this_frame[i] = nil
    end
end

return Setqueue
