local Object = require 'object'

local Recipe = {}

Recipe.wrapper = require 'recipe.wrapper'
Recipe.nested = require 'recipe.nested'

function Recipe.load(name)
    local recipe = Recipe.tryloadnested(name) or Recipe.tryloadlua(name)
    if recipe ~= nil then
        assertf(type(recipe) == 'table', "Recipe must be a table, found %q", type(recipe))
        assertf(recipe[1] ~= nil, "Recipe name expected as %q", name)
        assertf(recipe[1] == name, "Expected name in recipe %q to match file %q", recipe[1], name)
        if not getmetatable(recipe) then setmetatable(recipe, Recipe) end
        return recipe
    end
end

function Recipe.tryloadlua(filename)
    local lua_recipe = assert(love.filesystem.load(filename))()
    return lua_recipe
    -- for i, fmt in ipairs(Recipe.path) do
    --     local filename = string.format(fmt, name)
    --     if love.filesystem.getInfo(filename) then
    --     end
    -- end
    -- return nil
end

function Recipe.tryloadnested(filename)
    local contents = assert(love.filesystem.read(filename))
    return assert(Recipe.nested.load(filename, contents))
    -- for i, fmt in ipairs(Recipe.nestedpath) do
    --     local filename = string.format(fmt, name)
    --     if love.filesystem.getInfo(filename) then
    --         local contents = assert(love.filesystem.read(filename))
    --         return assert(Recipe.nested.load(name, filename, contents))
    --     end
    -- end
    -- return nil
end

Recipe.__call = Object.new

return Recipe