local Recipe = {}

Recipe.path = {'engine/wrapper/%s.lua', 'script/%s.lua'}
Recipe.nestedpath = {'script/%s.nested'}

function Recipe.load(name)
    local recipe = Recipe.tryloadlua(name) or Recipe.tryloadnested(name)
    if recipe ~= nil then
        assertf(type(recipe) == 'table', "Recipe must be a table, found %q", type(recipe))
        assertf(recipe[1] == nil or recipe[1] == name, "Expected name in recipe %q to match file %q", recipe[1], name)
        return setmetatable(recipe, {
            __index = Recipe,
            __call = Recipe.instantiate
        })
    end
end

function Recipe.tryloadlua(lowername)
    for i, fmt in ipairs(Recipe.path) do
        local filename = string.format(fmt, lowername)
        if love.filesystem.getInfo(filename) then
            return assert(love.filesystem.load(filename))()
        end
    end
    return nil
end

function Recipe.tryloadnested(lowername)
    for i, fmt in ipairs(Recipe.nestedpath) do
        local filename = string.format(fmt, lowername)
        if love.filesystem.getInfo(filename) then
            local contents = assert(love.filesystem.read(filename))
            return assert(nested.decode(contents, nested.bool_number_filter))
        end
    end
    return nil
end

local function instantiate_into(dest, recipe, root)
    for i = 2, #recipe do
        local t = recipe[i]
        local constructor = t[1] and R.recipe[t[1]] or deepcopy
        dest[#dest + 1] = constructor(t, root)
    end
end 

function Recipe:instantiate(overrides, root_param)
    local newobj = { self[1] }
    local root = root_param or newobj
    local fallback_index = self.__index or function(t, index) return rawget(self, index) end
    setmetatable(newobj, {
        __recipe = self,
        __root = root,
        __index = function(t, index)
            if index == 'root' then return root end
            if type(index) == 'string' then
                local expr = rawget(t, '$' .. index)
                if expr then return expr() end
            end
            return fallback_index(t, index)
        end, 
        __newindex = self.__newindex,
    })
    instantiate_into(newobj, self, root)
    if overrides then
        for k, v in nested.kpairs(overrides) do
            if type(k) == 'string' and k:sub(1, 1) == '$' then
                newobj[k] = Expression.new(v, newobj, root_param)
            else
                if k == 'id' then
                    root[v] = newobj
                end
                newobj[k] = deepcopy(v)
            end
        end
        instantiate_into(newobj, overrides, root)
    end

    if self.init then self.init(newobj) end
    return newobj
end

function Recipe:getRoot()
    return getmetatable(self).__root
end

return Recipe