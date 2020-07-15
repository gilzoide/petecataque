local Expression = require 'expression'
local Object = require 'object'

local wrapper = {}

local function field_name_less_getset(s)
    if s:startswith("get") or s:startswith("set") then
        s = string.format("%s%s", s:sub(4, 4):lower(), s:sub(5))
    end
    return s
end

local function create_getter(wrapped_getter_name)
    return Expression.getter_from_function(function(self)
        DEBUG.PUSH_CALL(self, wrapped_getter_name)
        local wrapped = self.__wrapped
        local value = wrapped and safepack(wrapped[wrapped_getter_name](wrapped)) or nil
        DEBUG.POP_CALL(self, wrapped_getter_name)
        return value
    end)
end

local function create_setter(wrapped_setter_name, field_name)
    return function(self, value)
        DEBUG.PUSH_CALL(self, wrapped_setter_name)
        local wrapped = self.__wrapped
        if wrapped then
            wrapped[wrapped_setter_name](wrapped, safeunpack(value))
        else
            if not self._wrapped_defer then self._wrapped_defer = {} end
            self._wrapped_defer[#self._wrapped_defer + 1] = { field_name, value }
        end
        DEBUG.POP_CALL(self, wrapped_setter_name)
    end
end

local function create_method(method_name)
    return function(self, ...)
        DEBUG.PUSH_CALL(self, method_name)
        local wrapped = self.__wrapped
        local value = wrapped and safepack(wrapped[method_name](wrapped, ...))
        DEBUG.POP_CALL(self, method_name)
        return value
    end
end

function wrapper.new(name, wrapped_object_index, getters, setters, othermethods)
    local recipe = { name }
    for i = 1, #getters do
        local getter = getters[i]
        local field_name = field_name_less_getset(getter)
        Object.add_getter(recipe, field_name, create_getter(getter))
    end

    for i = 1, #setters do
        local setter = setters[i]
        local field_name = field_name_less_getset(setter)
        Object.add_setter(recipe, field_name, create_setter(setter, field_name))
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
                self[t[1]] = t[2]
            end
            self._wrapped_defer = nil
        end
    end

    Object.add_getter(recipe, wrapped_object_index, wrapper.get_wrapped)

    return recipe
end

function wrapper.get_wrapped(self)
    return self.__wrapped
end

return wrapper