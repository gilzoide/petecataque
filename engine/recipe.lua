local Recipe = {}

Recipe.path = {'engine/wrapper/%s.lua', 'script/%s.lua'}
Recipe.nestedpath = {'script/%s.nested'}

function Recipe.load(name)
    local recipe = Recipe.tryloadlua(name) or Recipe.tryloadnested(name)
    assertf(type(recipe) == 'table', "Recipe must be a table, found %q", type(recipe))
    assertf(recipe[1] == nil or recipe[1] == name, "Expected name in recipe %q to match file %q", recipe[1], name)
    return setmetatable(recipe, { __index = Recipe, __call = Recipe.instantiate })
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

local function instantiate_into(dest, recipe)
    for i = 2, #recipe do
        local t = recipe[i]
        local constructor = assert(R.recipe[t[1]])
        dest[#dest + 1] = constructor(t)
    end
end

function Recipe:instantiate(overrides)
    local newobj = { self[1] }
    setmetatable(newobj, { __recipe = self, __index = self.__index or self, __newindex = self.__newindex })
    instantiate_into(newobj, self)
    if overrides then
        for k, v in nested.kpairs(overrides) do
            newobj[k] = deepcopy(v)
        end
        instantiate_into(newobj, overrides)
    end

    if self.init then self:init(newobj) end
    return newobj
end

return Recipe