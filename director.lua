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

function Director:register(obj, ...)
    local event = {...}
    local container = self.listeners
    for i, v in ipairs(event) do
        if container[v] == nil then container[v] = {} end
        container = container[v]
    end
    if not container[obj] then
        local key = #container + 1
        container[key] = obj
        container[obj] = key
    end
end

function Director:track_object_type(type_name)
    self.object_by_types[type_name] = {}
end

function Director:track_object(obj, type_name)
    local container = self.object_by_types[type_name]
    container[#container + 1] = obj
    if obj.draw then self.__draw[#self.__draw + 1] = obj end
    if obj.update then self.__update[#self.__update + 1] = obj end
end

function Director:process_event(ev)
    local listeners = self.listeners
    for i, v in ipairs(ev) do
        listeners = listeners[v]
        if not listeners then return end
        for i, obj in ipairs(listeners) do
            if not obj.disabled then
                local f = assert(is_type(obj[v], 'function'), 'Expected event listener to be a function')
                obj[v](unpack(ev, 2))
            end
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