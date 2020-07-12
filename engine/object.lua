local Object = {}

Object.GET_METHOD_PREFIX = '$'
Object.GET_ONCE_METHOD_PREFIX = '!'
Object.SET_METHOD_PREFIX = '$set '
Object.SET_METHOD_NO_RAWSET = 'SET_METHOD_NO_RAWSET'

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
    
function Object:type()
    return self[1]
end

function Object:typeOf(t)
    return self:type() == t
end

local function copy_into(dest, src, root, index_chain, defer_index_once)
    local special
    for k, v in nested.kpairs(src) do
        special, k = Object.IS_SPECIAL_METHOD_PREFIX(k)
        if special == 'get' then
            dest.__index_expression[k] = Expression.instantiate(v, index_chain)
        elseif special == 'set' then
            dest.__newindex_expression[k] = Expression.instantiate(v, index_chain)
        elseif special == 'once' then
            defer_index_once[#defer_index_once + 1] = { k, v }
        elseif k == 'update' then
            dest[k] = Expression.instantiate(v, index_chain)
        else
            if k == 'id' then
                root[v] = dest
            end
            dest[k] = deepcopy(v)
        end
    end
end
local function copy_expression_only_into(dest, src, root, index_chain, defer_index_once)
    local special
    for k, v in nested.kpairs(src) do
        special, k = Object.IS_SPECIAL_METHOD_PREFIX(k)
        if special == 'get' then
            dest.__index_expression[k] = Expression.instantiate(v, index_chain)
        elseif special == 'set' then
            dest.__newindex_expression[k] = Expression.instantiate(v, index_chain)
        elseif special == 'once' then
            defer_index_once[#defer_index_once + 1] = { k, v }
        end
    end
end
local function instantiate_into(dest, src, root)
    for i = 2, #src do
        local t = src[i]
        local recipe_name = assert(t[1], "Recipe must have a name")
        local constructor = assertf(R.recipe[recipe_name], "Recipe %q couldn't be loaded", recipe_name)
        dest[#dest + 1] = constructor(t, dest, root)
    end
end

function Object.new(recipe, overrides, parent, root_param)
    local newobj = setmetatable({
        recipe[1],
        __recipe = recipe,
        __parent = parent,
        __root = root_param,
        __index_chain = { recipe, Object },
        __index_expression = {},
        __newindex_expression = {},
        __in_middle_of_indexing = {},
    }, Object)
    local index_chain = { _ENV, newobj, root_param }
    local defer_index_once = {}
    local root = root_param or newobj
    copy_expression_only_into(newobj, recipe, root, index_chain, defer_index_once)
    if overrides then copy_into(newobj, overrides, root, index_chain, defer_index_once) end
    if recipe.preinit then Expression.call(recipe.preinit, index_chain, newobj) end
    instantiate_into(newobj, recipe, root)
    if overrides then instantiate_into(newobj, overrides, root) end

    for i = 1, #defer_index_once do
        local k, v = unpack(defer_index_once[i])
        newobj[k] = Expression.call(v, index_chain, newobj)
    end

    if recipe.init then Expression.call(recipe.init, index_chain, newobj) end
    if overrides and overrides.init then Expression.call(overrides.init, index_chain, newobj) end
    if newobj.when then
        for i = 1, #newobj.when do
            local t = newobj.when[i]
            t[2] = newobj:create_expression(t[2])
        end
    end
    return newobj
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
    if type(index) == 'string' and index:match('^[^_$]') then
        local in_middle_of_indexing = rawget(self, '__in_middle_of_indexing')  -- avoid infinite recursion
        if not in_middle_of_indexing[index] then 
            local expr = self.__index_expression[index]
            if expr then
                in_middle_of_indexing[index] = true
                local value = expr(self)
                in_middle_of_indexing[index] = nil
                if value ~= nil then
                    Object.__newindex(self, index, value)
                    return value
                end
            end
        end
        local value = rawget(self, '_' .. index)
        if value ~= nil then return value end
    end
    return index_first_of(index, rawget(self, '__index_chain'))
end

function Object:__newindex(index, value)
    if index == 'draw_push' then
        local valid = value == 'all' or value == 'transform'
        value = valid and value
        index = '_' .. index
    elseif type(index) == 'string' then
        if index:match('^[^_$]') then
            local set_method = self.__newindex_expression[index]
            if set_method then
                local result = set_method(self, value)
                if result == Object.SET_METHOD_NO_RAWSET then return
                elseif result ~= nil then value = result
                end
                index = '_' .. index
            elseif self.__index_expression[index] then
                -- avoid ignoring getter expressions
                index = '_' .. index
            end
        end
    end
    rawset(self, index, value)
end

function Object:__pairs()
    return coroutine.wrap(function()
        for k, v in rawpairs(self) do
            if type(k) == 'string' then
                if k:startswith('__') or k:startswith('$') then
                    k = nil
                elseif k:startswith('_') then
                    k = k:sub(2)
                end
            end
            if k then coroutine.yield(k, v) end
        end
    end)
end

function Object:iter_parents()
    local current = self
    return function()
        current = current.parent
        return current
    end
end
function Object:first_parent_with(field)
    for p in self:iter_parents() do
        if p[field] then
            return p
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

function Object:expressionify(field_name, ...)
    if self[field_name] then
        local expression = self:create_expression(self[field_name], ...)
        self[field_name] = expression
        return expression
    end
end

function Object:create_expression(v, ...)
    local index_chain = { _ENV, self, self.root }
    table_extend(index_chain, ...)
    return Expression.new(v, index_chain)
end

function Object:add_when(condition, func)
    if not self.also_when then self.also_when = {} end
    self.also_when[#self.also_when + 1] = { condition, self:create_expression(func) }
end

function Object:enable_method(method_name, enable)
    rawset(self, method_name, (enable or false) and nil)
    return enable
end

return Object