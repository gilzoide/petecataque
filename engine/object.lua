local Expression = require 'expression'

local Object = {}

Object.GET_METHOD_PREFIX = '$'
Object.GET_ONCE_METHOD_PREFIX = '!'
Object.SET_METHOD_PREFIX = '$set '
Object.SET_METHOD_NO_RAWSET = 'NO_RAWSET'
Object.SET_METHOD_ARGUMENT_NAMES = { 'self', 'value' }

function Object.IS_SPECIAL_METHOD_PREFIX(v)
    if type(v) == 'string' then
        if v:startswith(Object.SET_METHOD_PREFIX) then
            return 'set', v:sub(#Object.SET_METHOD_PREFIX + 1)
        elseif v:startswith(Object.GET_METHOD_PREFIX) then
            return 'get', v:sub(#Object.GET_METHOD_PREFIX + 1)
        elseif v:startswith(Object.GET_ONCE_METHOD_PREFIX) then
            return 'once', v:sub(#Object.GET_ONCE_METHOD_PREFIX + 1)
        end
    end
    return false, v
end

Object.type = Expression.getter_from_function(function(self) return self[1] end)

function Object:typeOf(t)
    return self.type == t
end

function Object.new(recipe, obj, parent, root_param)
    DEBUG.PUSH_CALL(recipe, "new")
    assertf(obj == nil or #obj == 0, "FIXME")
    obj = setmetatable(obj or {}, Object)
    obj[1] = recipe[1]
    rawset(obj, '__recipe', recipe)
    rawset(obj, '__parent', parent)
    rawset(obj, '__root', root_param)
    rawset(obj, '__in_middle_of_indexing', {})

    if recipe.preinit then
        DEBUG.PUSH_CALL(recipe, 'preinit')
        recipe.preinit(obj)
        DEBUG.POP_CALL(recipe, 'preinit')
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
    local value_in_recipe = index_first_of(index, rawget(self, '__recipe'), Object)
    if Expression.is_getter(value_in_recipe) then
        local in_middle_of_indexing = rawget(self, '__in_middle_of_indexing')  -- avoid infinite recursion
        if not in_middle_of_indexing[index] then
            DEBUG.PUSH_CALL(self, Object.GET_METHOD_PREFIX .. index)
            in_middle_of_indexing[index] = true
            local value = value_in_recipe(self)
            in_middle_of_indexing[index] = nil
            DEBUG.POP_CALL(self, Object.GET_METHOD_PREFIX .. index)
            if value ~= nil then
                rawset(self, '_' .. index, value)
                return value
            end
        end
    else
        return value_in_recipe
    end
end

function Object:__newindex(index, value)
    -- if index == 'draw_push' then
    --     local valid = value == 'all' or value == 'transform'
    --     value = valid and value
    --     index = '_' .. index
    -- elseif type(index) == 'string' then
    --     if index:match('^[^_$]') then
    --         local set_method = self.__newindex_expression[index]
    --         if set_method then
    --             DEBUG.PUSH_CALL(self[1], Object.SET_METHOD_PREFIX .. index)
    --             local result = set_method(self, value)
    --             DEBUG.POP_CALL(self[1], Object.SET_METHOD_PREFIX .. index)
    --             if result == Object.SET_METHOD_NO_RAWSET then return
    --             elseif result ~= nil then value = result
    --             end
    --             index = '_' .. index
    --         elseif self.__index_expression[index] then
    --             -- avoid ignoring getter expressions
    --             index = '_' .. index
    --         end
    --     end
    -- end
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
        if p[1] == typename then
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

return Object