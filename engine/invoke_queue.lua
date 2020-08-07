local InvokeQueue = {}
InvokeQueue.__index = InvokeQueue

function InvokeQueue.new()
    return setmetatable({
        future_frame = {},
        frame_count = 0,
    }, InvokeQueue)
end

function InvokeQueue:queue_after(n, ...)
    assertf(iscallable(...), "Queued invocation must be callable, got %s", type(...))
    local frame_queue = nested.get_or_create(self.future_frame, self.frame_count + n)
    table.insert(frame_queue, { ... })
end

function InvokeQueue:queue(...)
    return self:queue_after(1, ...)
end

function InvokeQueue:flip()
    local frame_count = self.frame_count + 1
    self.this_frame, self.future_frame[frame_count] = self.future_frame[frame_count], nil
    self.frame_count = frame_count
end

function InvokeQueue:frame_ended()
    local this_frame = self.this_frame
    if this_frame then
        for i, cmd in ipairs(this_frame) do
            cmd[1](unpack(cmd, 2))
        end
        self.this_frame = nil
    end
end

return InvokeQueue
