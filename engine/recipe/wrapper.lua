local Object = require 'object'

local wrapper = {}

local function get_getter_name(s)
    if s:startswith("get") then
        s = string.format("%s%s", s:sub(4, 4):lower(), s:sub(5))
    end
    return Object.GET_METHOD_PREFIX .. s
end

local function get_setter_name(s)
    if s:startswith("set") then
        s = string.format("%s%s", s:sub(4, 4):lower(), s:sub(5))
    end
    return Object.SET_METHOD_PREFIX .. s
end

local function create_getter(wrapped_getter_name)
    return function(self)
        DEBUG.PUSH_CALL(self[1], wrapped_getter_name)
        local wrapped = self.__wrapped
        local value = wrapped and safepack(wrapped[wrapped_getter_name](wrapped)) or nil
        DEBUG.POP_CALL(self[1], wrapped_getter_name)
        return value
    end
end

local function create_setter(wrapped_setter_name, setter_name)
    return function(self, value)
        DEBUG.PUSH_CALL(self[1], wrapped_setter_name)
        local wrapped = self.__wrapped
        if wrapped then
            wrapped[wrapped_setter_name](wrapped, safeunpack(value))
        else
            if not self._wrapped_defer then self._wrapped_defer = {} end
            self._wrapped_defer[#self._wrapped_defer + 1] = { setter_name, value }
        end
        DEBUG.POP_CALL(self[1], wrapped_setter_name)
        return Object.SET_METHOD_NO_RAWSET
    end
end

local function create_method(method_name)
    return function(self, ...)
        DEBUG.PUSH_CALL(self[1], method_name)
        local wrapped = self.__wrapped
        local value = wrapped and safepack(wrapped[method_name](wrapped, ...))
        DEBUG.POP_CALL(self[1], method_name)
        return value
    end
end

function wrapper.new(name, getters, setters, othermethods)
    local recipe = { name }
    for i = 1, #getters do
        local getter = getters[i]
        local getter_name = get_getter_name(getter)
        recipe[getter_name] = create_getter(getter)
    end

    for i = 1, #setters do
        local setter = setters[i]
        local setter_name = get_setter_name(setter)
        recipe[setter_name] = create_setter(setter, setter_name)
    end

    for i = 1, #othermethods do
        local method = othermethods[i]
        recipe[method] = create_method(method)
    end

    recipe.preinit = function(self)
        self.__wrapped = self:create_wrapped()
        if self._wrapped_defer then
            for i = 1, #self._wrapped_defer do
                local t = self._wrapped_defer[i]
                self[t[1]](self, t[2])
            end
            self._wrapped_defer = nil
        end
    end

    return recipe
end

function wrapper.get_wrapped(self)
    return self.__wrapped
end

return wrapper