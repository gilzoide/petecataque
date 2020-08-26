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
        local wrapped = self.__wrapped
        return wrapped and Object.invoke(wrapped, wrapped_getter_name) or self[_field_name]
    end)
end

local function create_setter(wrapped_setter_name, field_name)
    return function(self, value)
        local wrapped = self.__wrapped
        if wrapped then
            Object.invoke(wrapped, wrapped_setter_name, safeunpack(value))
        end
    end
end

local function create_method(method_name)
    return function(self, ...)
        local wrapped = self.__wrapped
        return wrapped and Object.invoke(wrapped, method_name, ...)
    end
end

function wrapper.new(name, options)
    assert(type(name) == 'string')
    local recipe = Recipe.new(name, options.extends)

    local added_getters
    if options.getters then
        added_getters = {}
        for i, getter in ipairs(options.getters) do
            local field_name = field_name_less_getset(getter)
            added_getters[field_name] = recipe:add_getter(field_name, create_getter(getter, field_name))
        end
    end

    if options.setters then
        for i, setter in ipairs(options.setters) do
            local field_name = field_name_less_getset(setter)
            recipe:add_setter(field_name, create_setter(setter, field_name))
        end
    end

    if options.methods then
        for i, method in ipairs(options.methods) do
            recipe[method] = create_method(method)
        end
    end

    recipe.preinit = function(self)
        if not self.__wrapped then
            self.__wrapped = self:invoke('create_wrapped', self)
        end
    end

    if options.wrapped_index then
        recipe:add_getter(options.wrapped_index, wrapper.get_wrapped)
    end

    if added_getters then
        recipe.__init_recipe = function(recipe, child)
            for k, v in pairs(added_getters) do
                local value_in_child = child[k]
                if value_in_child then
                    child['_' .. k], child[k] = value_in_child, nil
                end
            end
        end
    end

    return recipe
end

function wrapper.get_wrapped(self)
    return self.__wrapped
end

return wrapper
