local Recipe = {}

Recipe.path = {'engine/wrapper/%s.lua', 'script/%s.lua'}
Recipe.nestedpath = {'script/%s.nested'}

function Recipe.load(name)
    local lowername = name:lower()
    local recipe = Recipe.tryloadlua(lowername) or Recipe.tryloadnested(lowername)
    assertf(type(recipe) == 'table', "Recipe must be a table, found %q", type(recipe))
    assertf(recipe[1] == nil or string.lower(recipe[1]) == lowername, "Expected name in recipe %q to match file %q", string.lower(recipe[1]), lowername)
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
            local recipe = assert(nested.decode(contents, nested.bool_number_filter))
            function recipe:init()
                local recipe = assert(getmetatable(self).__recipe)
                local iterator = nested.iterate(recipe, { table_only = true })
                iterator() -- ignore root
                for kp, t in iterator do
                    local constructor = R.recipe[t[1]]
                    if constructor then
                        set_or_create(self, kp, constructor(t))
                    end
                end
            end
            return recipe
        end
    end
    return nil
end

function Recipe:instantiate(obj)
    obj = obj or {}
    obj[1] = self[1]
    setmetatable(obj, { __recipe = self, __index = self.__index or self, __newindex = self.__newindex })
    if self.init then self.init(obj) end
    return obj
end

return Recipe