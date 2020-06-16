local Director = {}
Director.__index = Director

function Director.new()
    return setmetatable({
        listeners = {},
        queued_events = {},
    }, Director)
end

function Director:register(event_pattern, handler)
    local event_name = event_pattern[1]
    assert(is_type(event_name, 'string'), 'Event name must be a string')
    assert(is_type(handler, 'function'), 'Event handler must be a function')
    local container = index_or_create(self.listeners, event_name)
    container[#container + 1] = { event_pattern, handler }
end

function Director:queue_event(ev)
    assert(is_type(ev, 'table') and is_type(ev[1], 'string'), 'Event must be a table and have a name')
    self.queued_events[#self.queued_events + 1] = ev
end

local function check_event_match(ev, pattern)
    for k, v in pairs(pattern) do
        if ev[k] ~= v then return false end
    end
    return true
end
function Director:process_event(ev)
    local listeners = self.listeners[ev[1]]
    if listeners == nil then return end
    for i = 1, #listeners do
        local listener = listeners[i]
        if check_event_match(ev, listener[1]) then
            listener[2](unpack(ev, 2))
        end
    end
end

function Director:update(dt)
    for kp, obj in nested.iterate(Scene) do
        if obj.update then obj.update(dt) end
    end
    
    local queued_events = self.queued_events
    if #queued_events == 0 then return end
    self.queued_events = {}
    for i, ev in ipairs(queued_events) do
        self:process_event(ev)
    end
end

function Director:draw()
    for kp, obj in nested.iterate(Scene) do
        if obj.draw then obj.draw() end
    end
end

return Director