local Object = require 'object'

local Recipe = {}

Recipe.wrapper = require 'recipe.wrapper'
Recipe.nested = require 'recipe.nested'
Recipe.path = {
    'engine/wrapper/%s.lua', 'engine/wrapper/drawable/%s.lua', 
    'engine/wrapper/graphics/%s.lua', 'engine/wrapper/physics/%s.lua',
    'script/%s.lua'
}
Recipe.nestedpath = {'script/%s.nested'}

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

function Recipe.preprocess(recipe)
    for kp, v, parent in nested.iterate(recipe, { include_kv = true }) do
        local key = kp[#kp]
        local special = Object.IS_SPECIAL_METHOD_PREFIX(key)
        if key == 'init' or key == 'update' or key == 'draw' then
            parent[key] = Expression.template(v)
        elseif key == 'when' then
            assertf(type(v) == 'table', "On recipe %q: Expected 'when' to be a table, found %q", recipe[1], type(value))
            for i = 1, #v do
                local t = v[i]
                t[2] = Expression.template(t[2])
            end
        elseif special then
            parent[key] = Expression.template(v, special == 'get' or special == 'once', special == 'set' and Object.SET_METHOD_ARGUMENT_NAMES)
        end
    end
end

function Recipe.tryloadlua(name)
    for i, fmt in ipairs(Recipe.path) do
        local filename = string.format(fmt, name)
        if love.filesystem.getInfo(filename) then
            local lua_recipe = assert(love.filesystem.load(filename))()
            Recipe.preprocess(lua_recipe)
            return lua_recipe
        end
    end
    return nil
end

function Recipe.tryloadnested(name)
    for i, fmt in ipairs(Recipe.nestedpath) do
        local filename = string.format(fmt, name)
        if love.filesystem.getInfo(filename) then
            local contents = assert(love.filesystem.read(filename))
            return assert(Recipe.nested.load(contents))
        end
    end
    return nil
end

Recipe.__call = Object.new

return Recipe