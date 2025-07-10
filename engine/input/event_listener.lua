local event_listener = {
    names = {}
}

function event_listener.new(name)
    local new_listener = setmetatable({}, event_listener)
    DEBUG.ONLY(function()
        if name then event_listener.names[new_listener] = name end
    end)
    return new_listener
end

function event_listener:add(obj, callback)
    self[obj] = callback
end

function event_listener:remove(obj)
    self[obj] = nil
end

function event_listener:emit(...)
    for obj, callback in pairs(self) do
        DEBUG.PUSH_CALL(obj, event_listener.names[self])
        callback(obj, ...)
        DEBUG.POP_CALL(obj, event_listener.names[self])
    end
end

local methods = {
    add = event_listener.add,
    remove = event_listener.remove,
    emit = event_listener.emit,
}
event_listener.__index = methods
event_listener.__mode = 'k'
event_listener.__call = event_listener.emit

return event_listener
