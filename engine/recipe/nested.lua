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

local preprocess_iterate_flags = { table_only = true }
function recipe_nested.preprocess(name, recipe)
    local recipe_name = recipe[1]
    if type(recipe_name) ~= 'string' then
        table.insert(recipe, 1, name)
    else
        if recipe_name ~= name then
            Recipe.extends(recipe, recipe_name)
            recipe[1] = name
        end
    end

    for kp, t, parent in nested.iterate(recipe, preprocess_iterate_flags) do
        for k, v in nested.kpairs(t) do
            if type(v) == 'table' and v.__opening_token == '{' then
                t[k] = Expression.from_table(v, v.__file, v.__line)
            end
            if type(k) == 'string' and k:startswith(Object.SET_METHOD_PREFIX) then
                Expression.bind_argument_names(v, Object.SET_METHOD_ARGUMENT_NAMES)
            end
        end
        if #kp > 0 then
            local super_recipe_name = t[1]
            assertf(super_recipe_name[1] ~= recipe[1], "Cannot have recursive recipes @ %s:%s", super_recipe_name.__file, super_recipe_name.__line)
            t.__parent = parent
            Recipe.extends(t, super_recipe_name)
        end
        setmetatable(t, Recipe)
    end
end

return recipe_nested
