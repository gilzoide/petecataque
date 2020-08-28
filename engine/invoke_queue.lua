local table_pool = require 'table_pool'.raw

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
    local frame_count = self.frame_count + n
    local frame_queue = self.future_frame[frame_count]
    if not frame_queue then
        frame_queue = table_pool:acquire()
        self.future_frame[frame_count] = frame_queue
    end
    local t = table_pool:acquire()
    for i = 1, select('#', ...) + 1 do
        t[i] = select(i, ...)
    end
    table.insert(frame_queue, t)
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
        for i = 1, #this_frame do
            local cmd = this_frame[i]
            cmd[1](unpack(cmd, 2))
            table_pool:release(cmd)
            this_frame[i] = nil
        end
        table_pool:release(this_frame)
        self.this_frame = nil
    end
end

return InvokeQueue
