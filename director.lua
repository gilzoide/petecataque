--[[
-- Events are tables with identifiers, like {'draw'} or {'update'} or {'key', 'a', 'pressed'}
-- Listeners can register themselves on events with any specificity, so they can listen for
--   {'key'} or {'key', 'a'} only, for example.
-- Objects receive a call for the method with the first identifier as name, receiving every
--   specificity as arguments.
--]]

local nested = require 'lib.nested'

local Director = {}
Director.__index = Director

function Director.new()
    return setmetatable({
        listeners = {},
        queued_events = {},
        __draw = {},
        __update = {},
    }, Director)
end

function Director:register(...)
    local event = {...}
    local handler = table.remove(event)
    assert(is_type(handler, 'function'), 'Event listener must be a function')
    local container = self.listeners
    for i = 1, #event do
        local v = event[i]
        if container[v] == nil then container[v] = {} end
        container = container[v]
    end
    container[#container + 1] = handler
end

function Director:queue_event(...)
    self.queued_events[#self.queued_events + 1] = {...}
end

function Director:process_event(ev)
    local listeners = self.listeners
    for i = 1, #ev do
        local specificity = ev[i]
        listeners = listeners[specificity]
        if not listeners then return end
        for _, handler in ipairs(listeners) do
            handler(unpack(ev, i + 1))
        end
    end
end

function Director:update(dt)
    for kp, obj in nested.iterate(State) do
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
    for kp, obj in nested.iterate(State) do
        if obj.draw then obj.draw() end
    end
end

return Director