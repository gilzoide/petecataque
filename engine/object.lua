local Object = {}

Object.GET_METHOD_PREFIX = '$'
Object.SET_METHOD_PREFIX = '$set'

function Object:type()
    return self[1]
end

function Object:typeOf(t)
    return self:type() == t
end

local function copy_into(dest, src, root, index_chain)
    for k, v in nested.kpairs(src) do
        if type(k) == 'string' and k:startswith(Object.GET_METHOD_PREFIX) then
            dest[k] = Expression.new(v, index_chain)
        elseif k ~= 'init' and type(v) ~= 'function' then
            if k == 'id' then
                root[v] = dest
            end
            dest[k] = deepcopy(v)
        end
    end
end
local function instantiate_into(dest, src, root)
    for i = 2, #src do
        local t = src[i]
        local constructor = t[1] and R.recipe[t[1]] or deepcopy
        dest[#dest + 1] = constructor(t, dest, root)
    end
end

function Object.new(recipe, overrides, parent, root_param)
    local newobj = setmetatable({
        recipe[1],
        __recipe = recipe,
        __parent = parent,
        __root = root_param,
        __index_chain = { recipe, Object }
    }, Object)
    local index_chain = { newobj, root_param, _ENV }
    local root = root_param or newobj
    copy_into(newobj, recipe, root, index_chain)
    if recipe.preinit then Expression.call(recipe.preinit, index_chain, newobj) end
    instantiate_into(newobj, recipe, root)
    if overrides then
        copy_into(newobj, overrides, root, index_chain)
        instantiate_into(newobj, overrides, root)
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
    if type(index) == 'string' then
        local expr = rawget_self_or_recipe(self, Object.GET_METHOD_PREFIX .. index)
        if expr then
            local value = expr(self)
            if value ~= nil then
                Object.__newindex(self, index, value)
                return value
            end
        end
        local value = rawget(self, '_' .. index)
        if value ~= nil then return value end
    end
    return index_first_of(index, rawget(self, '__index_chain'))
end

function Object:__newindex(index, value)
    if type(index) == 'string' then
        if index:match('^[^_$]') then
            local set_method = rawget_self_or_recipe(self, Object.SET_METHOD_PREFIX .. index)
            if set_method then return set_method(self, value) end
            index = '_' .. index
        end
    end
    rawset(self, index, value)
end

function Object:__pairs()
    return coroutine.wrap(function()
        for k, v in rawpairs(self) do
            if type(k) == 'string' then
                if k:match('^_[^_]') then
                    coroutine.yield(k:sub(2), v)
                end
            else
                coroutine.yield(k, v)
            end
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

function Object:expressionify(field_name, ...)
    if self[field_name] then
        local expression = self:create_expression(self[field_name], ...)
        self[field_name] = expression
        return expression
    end
end

function Object:create_expression(v, ...)
    local index_chain = { self, self.root, _ENV }
    table_extend(index_chain, ...)
    return Expression.new(v, index_chain)
end

function Object:add_when(condition, func)
    if not self.also_when then self.also_when = {} end
    self.also_when[#self.also_when + 1] = { condition, self:create_expression(func) }
end

return Object