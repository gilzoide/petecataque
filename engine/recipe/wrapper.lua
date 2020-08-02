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

local function create_getter(wrapped_getter_name, field_name)
    local _field_name = '_' .. field_name
    return Expression.getter_from_function(function(self)
        DEBUG.PUSH_CALL(self, wrapped_getter_name)
        local wrapped = self.__wrapped
        local value = wrapped and safepack(wrapped[wrapped_getter_name](wrapped)) or self[_field_name]
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

function wrapper.new(name, options)
    assert(type(name) == 'string')
    local recipe = Recipe.new(name, options.extends)

    if options.getters then
        for i, getter in ipairs(options.getters) do
            local field_name = field_name_less_getset(getter)
            Object.add_getter(recipe, field_name, create_getter(getter, field_name))
        end
    end

    if options.setters then
        for i, setter in ipairs(options.setters) do
            local field_name = field_name_less_getset(setter)
            Object.add_setter(recipe, field_name, create_setter(setter, field_name))
        end
    end

    if options.methods then
        for i, method in ipairs(options.methods) do
            recipe[method] = create_method(method)
        end
    end

    recipe.preinit = function(self)
        DEBUG.PUSH_CALL(self, 'create_wrapped')
        self.__wrapped = recipe.create_wrapped(self)
        DEBUG.POP_CALL(self, 'create_wrapped')
    end

    if options.wrapped_index then
        Object.add_getter(recipe, options.wrapped_index, wrapper.get_wrapped)
    end

    recipe.__init_recipe = wrapper.init_recipe

    return recipe
end

function wrapper.get_wrapped(self)
    return self.__wrapped
end

function wrapper.init_recipe(super, child)
    for k, v in nested.kpairs(super) do
        if Expression.is_getter(v) and v[2] ~= wrapper.get_wrapped then
            local value_in_child = child[k]
            if value_in_child then
                child['_' .. k], child[k] = value_in_child, nil
            end
        end
    end
end

return wrapper
