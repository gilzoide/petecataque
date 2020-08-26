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

local iterator_flags = { table_only = true }

local function decode_recipe(text, recipe_name, filename)
    local current, key = Recipe.new(recipe_name), 1
    local table_stack, first_non_numeric_key = { current }, nil
    for line, column, event, token, quote in nested.decode_iterate(text) do
        if event == 'TEXT' then
            -- recipe names
            if not first_non_numeric_key and key == 1 then
                if #table_stack == 1 then
                    Recipe.extends(current, token)
                else
                    current[1] = token
                    Recipe.recipify(current, token)
                end
                current.__file, current.__line = filename, line
            else
                local value = text_filter(token, quote, filename, line)
                if value == nil then value = token end
                current[key] = value
            end
            key = #current + 1
        elseif event == 'KEY' then
            key = token
        elseif event == 'OPEN_NESTED' then
            local nested_table = {}
            current[key] = nested_table
            table.insert(table_stack, nested_table)
            current = nested_table
            if not first_non_numeric_key and type(key) ~= 'number' then
                first_non_numeric_key = #table_stack
            end
            key = #current + 1
        elseif event == 'CLOSE_NESTED' then
            table.remove(table_stack)
            current = table_stack[#table_stack]
            if first_non_numeric_key and first_non_numeric_key > #table_stack then
                first_non_numeric_key = nil
            end
            key = #current + 1
        elseif event == 'ERROR' then
            return nil, string.format('Error at line %u (col %u): %s', line, column, token)
        end
    end
    for kp, obj, parent in nested.iterate(current, iterator_flags) do
        for super in Recipe.iter_super_chain(obj) do
            super:invoke_raw('__init_recipe', super, obj)
        end
    end
    return current
end

function recipe_nested.load(filename, contents)
    local name = AssetMap.get_basename(filename)
    return assert(decode_recipe(contents, name, filename))
end

return recipe_nested
