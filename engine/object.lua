local Expression = require 'expression'

local Object = {}

Object.SET_METHOD_PREFIX = '$set '
function Object.setter_method_name(field)
    return Object.SET_METHOD_PREFIX .. field
end

function Object.add_getter(self_or_recipe, field_name, getter_or_func)
    if not Expression.is_getter(getter_or_func) then
        getter_or_func = Expression.getter_from_function(getter_or_func)
    end
    self_or_recipe[field_name] = getter_or_func
end

Object.SET_METHOD_ARGUMENT_NAMES = { 'value' }
function Object.add_setter(self_or_recipe, field_name, function_or_expression)
    Expression.bind_argument_names(function_or_expression, Object.SET_METHOD_ARGUMENT_NAMES)
    self_or_recipe[Object.setter_method_name(field_name)] = function_or_expression
end

function Object:type()
    return self[1]
end

function Object:typeOf(t)
    return self[1] == t
end

function Object.new(recipe, obj, parent, root_param)
    DEBUG.PUSH_CALL(recipe, "new")
    assertf(obj == nil or #obj == 0, "FIXME %q", nested.encode(obj))
    obj = setmetatable(obj or {}, Object)
    obj[1] = recipe[1]
    rawset(obj, '__recipe', recipe)
    rawset(obj, '__parent', parent)
    rawset(obj, '__root', root_param)
    rawset(obj, '__in_middle_of_indexing', {})

    if root_param and recipe.id then
        root_param[recipe.id] = obj
    end

    if recipe.preinit then
        DEBUG.PUSH_CALL(recipe, 'preinit')
        recipe.preinit(obj)
        DEBUG.POP_CALL(recipe, 'preinit')
    end

    for k, v in nested.kpairs(recipe) do
        if type(k) == 'string' and recipe[Object.setter_method_name(k)] then
            if Expression.is_getter(v) then v = v(obj) end
            obj[k] = v
        end
    end

    local super = recipe.__super
    if super then
        for i = 2, #super do
            obj[#obj + 1] = super[i]({}, obj, obj)
        end
    end

    local root_or_obj = root_param or obj
    for i = 2, #recipe do
        obj[#obj + 1] = recipe[i]({}, obj, root_or_obj)
    end

    if recipe.init then
        DEBUG.PUSH_CALL(recipe, 'init')
        recipe.init(obj)
        DEBUG.POP_CALL(recipe, 'init')
    end

    DEBUG.POP_CALL(recipe, "new")
    
    return obj
end

local function rawget_self_or_recipe(self, index)
    local value = rawget(self, index)
    if value ~= nil then return value end
    return rawget(rawget(self, '__recipe'), index)
end

function Object:__index(index)
    if index == 'self' then return self end
    if index == 'recipe' then return rawget(self, '__recipe') end
    if index == 'root' then return rawget(self, '__root') end
    if index == 'parent' then return rawget(self, '__parent') end
    local value_in_recipe = rawget(self, '__recipe')[index]
    if Expression.is_getter(value_in_recipe) then
        local in_middle_of_indexing = rawget(self, '__in_middle_of_indexing')  -- avoid possible infinite recursion
        if not in_middle_of_indexing[index] then
            DEBUG.PUSH_CALL(self, index)
            in_middle_of_indexing[index] = true
            local value = value_in_recipe(self)
            in_middle_of_indexing[index] = nil
            DEBUG.POP_CALL(self, index)
            if value ~= nil then
                Object.__newindex(self, index, value)  -- invoke setter if necessary
                return value
            end
        end
    elseif value_in_recipe ~= nil then
        return value_in_recipe
    elseif index ~= 'update' and index ~= 'draw' and index ~= 'draw_push' and index ~= 'hidden' then
        return index_first_of(index, rawget(self, '__root'), Object)
    end
end

function Object:__newindex(index, value)
    if type(index) == 'string' then
        local recipe = rawget(self, '__recipe')
        local set_method_index = Object.setter_method_name(index)
        local set_method = index_first_of(set_method_index, recipe, Object)
        if iscallable(set_method) then
            DEBUG.PUSH_CALL(self, set_method_index)
            set_method(self, value)
            DEBUG.POP_CALL(self, set_method_index)
            index = '_' .. index
        elseif Expression.is_getter(recipe[index]) then
            -- avoid ignoring getter expressions
            index = '_' .. index
        end
    end
    rawset(self, index, value)
end

Object.__pairs = default_object_pairs

function Object:iter_parents()
    local current = self
    return function()
        current = current.parent
        return current
    end
end
function Object:first_parent_with(field)
    for p in self:iter_parents() do
        local value = p[field]
        if value then
            return p, value
        end
    end
end
function Object:first_parent_of(typename)
    for p in self:iter_parents() do
        if p:typeOf(typename) then
            return p
        end
    end
end

function Object:iter_children()
    local i = 1
    return function()
        i = i + 1
        return self[i]
    end
end
function Object:child_count()
    assert(#self >= 1, "FIXME object with '< 1' children")
    return #self - 1
end

function Object:expressionify(field_name, argument_names)
    if self[field_name] then
        local expression = self:create_expression(self[field_name], argument_names)
        self[field_name] = expression
        return expression
    end
end

function Object:create_expression(v, argument_names)
    local index_chain = { _ENV, self, self.root }
    return Expression.new(v, index_chain, false, argument_names)
end

function Object:enable_method(method_name, enable)
    rawset(self, method_name, (enable or false) and nil)
    return enable
end
function Object:disable_method(method_name, disable)
    return self:enable_method(method_name, not disable)
end

return Object