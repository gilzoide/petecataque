local Object = {}

function Object:type()
    return self[1]
end

function Object:typeOf(t)
    return self:type() == t
end

local function instantiate_into(dest, recipe, root)
    for i = 2, #recipe do
        local t = recipe[i]
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
    local root = root_param or newobj
    instantiate_into(newobj, recipe, root)
    if overrides then
        for k, v in nested.kpairs(overrides) do
            if type(k) == 'string' and k:sub(1, 1) == '$' then
                newobj[k] = Expression.new(v, { newobj, root_param, _ENV })
            else
                if k == 'id' then
                    root[v] = newobj
                end
                newobj[k] = deepcopy(v)
            end
        end
        instantiate_into(newobj, overrides, root)
    end

    if recipe.init then recipe.init(newobj) end
    return newobj
end

function Object:__index(index)
    if index == 'self' then return self end
    if index == 'recipe' then return rawget(self, '__recipe') end
    if index == 'root' then return rawget(self, '__root') end
    if index == 'parent' then return rawget(self, '__parent') end
    if type(index) == 'string' then
        local value = rawget(self, '$' .. index)
        if value then
            value = value(self)
            Object.__newindex(self, index, value)
            return value
        end
        value = rawget(self, '_' .. index)
        if value ~= nil then return value end
    end
    return index_first_of(index, rawget(self, '__index_chain'))
end

function Object:__newindex(index, value)
    if type(index) == 'string' and index:match('^[^_$]') then index = '_' .. index end
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

function Object:expressionify(field_name, ...)
    if self[field_name] then
        local index_chain = { self, self.root, _ENV }
        table_extend(index_chain, ...)
        self[field_name] = Expression.new(self[field_name], index_chain)
    end
end

return Object