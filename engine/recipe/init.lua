local Object = require 'object'

local Recipe = {}

Recipe.wrapper = require 'recipe.wrapper'
Recipe.nested = require 'recipe.nested'

function Recipe.new(name, super)
    return Recipe.recipify({ name }, super)
end

function Recipe.recipify(t, super)
    if super then Recipe.extends(t, super) end
    return setmetatable(t, Recipe)
end

function Recipe.extends(recipe, super)
    DEBUG.PUSH_CALL(recipe, 'extends')
    if type(super) == 'string' then
        super = R(super)
    end
    assertf(Recipe.is_recipe(super), "Invalid super definition %q", type(super))
    recipe.__super = super
    DEBUG.POP_CALL(recipe, 'extends')
end
local function yield_super(recipe)
    local super = recipe.__super
    if super then
        yield_super(super)
        coroutine.yield(super)
    end
end
function Recipe.iter_super_chain(recipe)
    return coroutine.wrap(function() yield_super(recipe) end)
end

function Recipe.is_recipe(v)
    return getmetatable(v) == Recipe
end

function Recipe:add_getter(field_name, getter_or_func)
    if not Expression.is_getter(getter_or_func) then
        getter_or_func = Expression.getter_from_function(getter_or_func)
    end
    rawset(self, field_name, getter_or_func)
    return getter_or_func
end
local SET_METHOD_PREFIX = 'set '
local SET_METHOD_PATT = 'set[ \t]+(.+)'
local SET_METHOD_ARGUMENT_NAMES = { 'value' }
function Recipe:add_setter(field_name, function_or_expression)
    Expression.bind_argument_names(function_or_expression, SET_METHOD_ARGUMENT_NAMES)
    rawset(self, SET_METHOD_PREFIX .. field_name, function_or_expression)
    return function_or_expression
end

function Recipe.setter_method_name(field_name)
    return SET_METHOD_PREFIX .. field_name
end
function Recipe:setter_for(field_name)
    return self[SET_METHOD_PREFIX .. field_name]
end

function Recipe:invoke(method_name, obj, ...)
    local method, result = self[method_name]
    if method then
        DEBUG.PUSH_CALL(self, method_name)
        result = safepack(method(obj, ...))
        DEBUG.POP_CALL(self, method_name)
    end
    return result
end
function Recipe:invoke_raw(method_name, obj, ...)
    local method, result = rawget(self, method_name)
    if method then
        DEBUG.PUSH_CALL(self, method_name)
        result = safepack(method(obj, ...))
        DEBUG.POP_CALL(self, method_name)
    end
    return result
end
function Recipe:invoke_super(...)
    local super = rawget(self, '__super')
    return super and super:invoke(...)
end

local methods = {
    iter_super_chain = Recipe.iter_super_chain,
    add_getter = Recipe.add_getter,
    add_setter = Recipe.add_setter,
    setter_for = Recipe.setter_for,
    invoke = Recipe.invoke,
    invoke_raw = Recipe.invoke,
    invoke_super = Recipe.invoke_super,
}
function Recipe:__index(index)
    if methods[index] then return methods[index] end
    local super = rawget(self, '__super')
    return super and super[index]
end
function Recipe:__newindex(index, value)
    if iscallable(value) then
        local setter_field_name = type(index) == 'string' and index:match(SET_METHOD_PATT)
        if setter_field_name then
            Recipe.add_setter(self, setter_field_name, value)
            return
        elseif Expression.is_getter(value) then
            Recipe.add_getter(self, index, value)
            return
        end
    end
    rawset(self, index, value)
end
Recipe.__pairs = default_object_pairs
Recipe.__call = Object.new

-- Loading from file
function Recipe.load_lua(filename)
    return assert(love.filesystem.load(filename))()
end

function Recipe.load_nested(filename)
    local contents, size = assert(love.filesystem.read(filename))
    return assert(Recipe.nested.load(filename, contents))
end


return Recipe
