local Object = require 'object'

local Recipe = {}

Recipe.wrapper = require 'recipe.wrapper'
Recipe.nested = require 'recipe.nested'

function Recipe.new(name, super)
    local recipe = { name }
    if super then Recipe.extends(recipe, super) end
    return setmetatable(recipe, Recipe)
end

function Recipe.extends(recipe, super)
    if type(super) == 'string' then
        super = R(super)
    end
    assertf(type(super) == 'table', "Invalid super definition %s", type(super))
    recipe.__super = super
    if super.__init_recipe then
        DEBUG.PUSH_CALL(recipe, '__init_recipe')
        super:__init_recipe(recipe)
        DEBUG.POP_CALL(recipe, '__init_recipe')
    end
end

function Recipe.is_recipe(v)
    return getmetatable(v) == Recipe
end

function Recipe.load_lua(filename)
    local lua_recipe = assert(love.filesystem.load(filename))()
    assertf(Recipe.is_recipe(lua_recipe), "Expected Lua recipe return from %q", filename)
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