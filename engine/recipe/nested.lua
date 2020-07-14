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
    if opening == '{' then
        return Expression.new(file, line)
    else
        local t = nested_ordered.new()
        rawset(t, '__file', file)
        rawset(t, '__line', line)
        return t
    end
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

    for kp, t, parent in nested.iterate(recipe, { table_only = true, skip_root = true }) do
        local subrecipe_name = t[1]
        assertf(subrecipe_name[1] ~= recipe[1], "Cannot have recursive recipes @ %s:%s", subrecipe_name.__file, subrecipe_name.__line)
        local subrecipe = assertf(R.recipe[subrecipe_name], "Recipe %q couldn't be loaded", subrecipe_name)
        t.__recipe = subrecipe
        t.__parent = parent
        setmetatable(t, recipe_nested)
    end
    setmetatable(recipe, recipe_nested)
end

function recipe_nested.__index(t, index)
    if index == 'recipe' then return rawget(t, '__recipe') end
    if index == 'parent' then return rawget(t, '__parent') end
    local super = rawget(t, '__recipe')
    return super and super[index]
end
recipe_nested.__pairs = Object.__pairs
recipe_nested.__call = Object.new

return recipe_nested