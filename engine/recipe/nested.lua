local Object = require 'object'

local recipe_nested = {}

local function text_filter(s, quotes, file, line)
    if quotes == '`' then
        return Expression.from_string(s, file, line)
    else
        return nested.bool_number_filter(s, quotes, line)
    end
end

local function table_constructor(opening, file, line)
    local t = nested_ordered.new()
    rawset(t, '__opening_token', opening)
    rawset(t, '__file', file)
    rawset(t, '__line', line)
    return t
end

local function bind_file_to_constructors(file)
    return function(s, quotes, line)
        return text_filter(s, quotes, file, line)
    end, function(opening, line)
        return table_constructor(opening, file, line)
    end
end

function recipe_nested.load(name, filename, contents)
    local recipe = assert(nested.decode(contents, bind_file_to_constructors(filename)))
    recipe_nested.preprocess(name, recipe)
    return recipe
end

function recipe_nested.preprocess(name, recipe)
    assertf(recipe[1] ~= nil, "Recipe name expected as %q @ %s", name, recipe.__file)
    assertf(recipe[1] == name, "Expected name in recipe %q to match file %q", recipe[1], name)

    for kp, t, parent in nested.iterate(recipe, { table_only = true }) do
        if #kp > 0 then
            local super_recipe_name = t[1]
            assertf(super_recipe_name[1] ~= recipe[1], "Cannot have recursive recipes @ %s:%s", super_recipe_name.__file, super_recipe_name.__line)
            local super_recipe = assertf(R.recipe[super_recipe_name], "Recipe %q couldn't be loaded", super_recipe_name)
            t.__super = super_recipe
            t.__parent = parent
            if super_recipe.__init_recipe then
                DEBUG.PUSH_CALL(t, '__init_recipe')
                super_recipe:__init_recipe(t)
                DEBUG.POP_CALL(t, '__init_recipe')
            end
        end
        for k, v in nested.kpairs(t) do
            if type(v) == 'table' and v.__opening_token == '{' then
                t[k] = Expression.from_table(v, v.__file, v.__line)
            end
        end
        setmetatable(t, recipe_nested)
    end
end

function recipe_nested.__index(t, index)
    local super = rawget(t, '__super')
    return super and super[index]
end
recipe_nested.__pairs = Object.__pairs
recipe_nested.__call = Object.new

return recipe_nested