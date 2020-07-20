local Object = require 'object'

local Recipe = {}

Recipe.wrapper = require 'recipe.wrapper'
Recipe.nested = require 'recipe.nested'

function Recipe.new(name, super)
    local recipe = { name, __super = super }
    return setmetatable(recipe, Recipe)
end

function Recipe.load_lua(filename)
    local lua_recipe = assert(love.filesystem.load(filename))()
    assert(getmetatable(lua_recipe) == Recipe, "Expected Lua recipe ")
    return lua_recipe
end

function Recipe.load_nested(filename)
    local contents, size = assert(love.filesystem.read(filename))
    return assert(Recipe.nested.load(filename, contents))
end

function Recipe.__index(t, index)
    local super = rawget(t, '__super')
    return super and super[index]
end
Recipe.__pairs = default_object_pairs
Recipe.__call = Object.new

return Recipe