local event_listener = {}

function event_listener.new(name)
    return setmetatable({ __name = name }, event_listener)
end

function event_listener:add(obj, callback)
    self[obj] = callback
end

function event_listener:remove(obj)
    self[obj] = nil
end

function event_listener:emit(...)
    for obj, callback in pairs(self) do
        DEBUG.PUSH_CALL(obj, self.__name)
        callback(obj, ...)
        DEBUG.POP_CALL(obj, self.__name)
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
event_listener.__pairs = default_object_pairs

return event_listener
