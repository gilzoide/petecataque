local Expression = require 'expression'
local Object = require 'object'

local wrapper = {}

local function field_name_less_getset(s)
    if s:startswith("get") or s:startswith("set") then
        s = string.format("%s%s", s:sub(4, 4):lower(), s:sub(5))
    elseif s:startswith("is") then
        s = string.format("%s%s", s:sub(3, 3):lower(), s:sub(4))
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
    local recipe = Recipe.new(name)

    if getters then
        for i = 1, #getters do
            local getter = getters[i]
            local field_name = field_name_less_getset(getter)
            Object.add_getter(recipe, field_name, create_getter(getter))
        end
    end

    if setters then
        for i = 1, #setters do
            local setter = setters[i]
            local field_name = field_name_less_getset(setter)
            Object.add_setter(recipe, field_name, create_setter(setter, field_name))
        end
    end

    if othermethods then
        for i = 1, #othermethods do
            local method = othermethods[i]
            recipe[method] = create_method(method)
        end
    end

    recipe.preinit = function(self)
        DEBUG.PUSH_CALL(self, 'create_wrapped')
        self.__wrapped = recipe.create_wrapped(self)
        DEBUG.POP_CALL(self, 'create_wrapped')
        for k, v in pairs(self.__recipe.wrapper_initial_getters) do
            if Expression.is_getter(v) then v = v(self) end
            self[k] = v
        end
    end

    if wrapped_object_index then
        Object.add_getter(recipe, wrapped_object_index, wrapper.get_wrapped)
    end

    recipe.__init_recipe = wrapper.init_recipe

    return recipe
end

function wrapper.get_wrapped(self)
    return self.__wrapped
end

function wrapper.init_recipe(self, recipe)
    local wrapper_initial_getters = nested_ordered.new()
    for k, v in nested.kpairs(recipe) do
        local value_in_self = self[k]
        if Expression.is_getter(value_in_self) and value_in_self[2] ~= wrapper.get_wrapped then
            wrapper_initial_getters[k] = v
            recipe[k] = nil
        end
    end
    recipe.wrapper_initial_getters = wrapper_initial_getters
end

return wrapper