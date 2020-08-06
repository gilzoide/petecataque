local AssetMap = require 'resources.asset_map'
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

function recipe_nested.load(filename, contents)
    local recipe = assert(nested.decode(contents, bind_file_to_constructors(filename)))
    local name = AssetMap.get_basename(filename)
    recipe_nested.preprocess(name, recipe)
    return recipe
end

function recipe_nested.new(name, recipe)
    assertf(type(recipe) == 'table', "Nested recipe must be a table, found %s", type(recipe))
    recipe_nested.preprocess(name, recipe)
    return recipe
end

local function preprocess_getset(t)
    for k, v in nested.kpairs(t) do
        if type(v) == 'table' and v.__opening_token == '{' then
            t[k] = Expression.from_table(v, v.__file, v.__line)
        end
        if type(k) == 'string' and k:startswith(Object.SET_METHOD_PREFIX) then
            Expression.bind_argument_names(v, Object.SET_METHOD_ARGUMENT_NAMES)
        end
    end
end

local preprocess_iterate_flags = { table_only = true, skip_root = true }
function recipe_nested.preprocess(name, recipe)
    preprocess_getset(recipe)
    local recipe_name = recipe[1]
    if type(recipe_name) ~= 'string' then
        table.insert(recipe, 1, name)
    else
        if recipe_name ~= name then
            recipe[1] = name
            Recipe.extends(recipe, recipe_name)
        end
    end
    setmetatable(recipe, Recipe)

    for kp, t, parent in nested.iterate(recipe, preprocess_iterate_flags) do
        preprocess_getset(t)
        local super_recipe_name = t[1]
        assertf(super_recipe_name[1] ~= recipe[1], "Cannot have recursive recipes @ %s:%s", super_recipe_name.__file, super_recipe_name.__line)
        t.__parent = parent
        Recipe.extends(t, super_recipe_name)
        setmetatable(t, Recipe)
    end
end

return recipe_nested
