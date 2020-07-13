local Object = require 'object'

local recipe_nested = {}

recipe_nested.INDEX_EXPRESSIONS = '__index_expressions'
recipe_nested.NEWINDEX_EXPRESSIONS = '__newindex_expressions'
recipe_nested.PREINIT_EXPRESSIONS = '__preinit_expressions'
recipe_nested.OTHER_VALUES = '__other_values'

local function construct_with_line(opening, line)
    return setmetatable({
        __line = line,
        [recipe_nested.OTHER_VALUES] = {},
    }, recipe_nested)
end

function recipe_nested.load(contents)
    return nested.decode(contents, nested.bool_number_filter, construct_with_line)
end

function recipe_nested:__newindex(index, value)
    local special = Object.IS_SPECIAL_METHOD_PREFIX(index)
    if special == 'get' then
        local index_expressions = rawget(self, recipe_nested.INDEX_EXPRESSIONS)
        if not index_expressions then index_expressions = {}; rawset(self, recipe_nested.INDEX_EXPRESSIONS, index_expressions) end
        value = Expression.template(value, true)
        index_expressions[index] = value
    elseif special == 'set' then
        local newindex_expressions = rawget(self, recipe_nested.NEWINDEX_EXPRESSIONS)
        if not newindex_expressions then newindex_expressions = {}; rawset(self, recipe_nested.NEWINDEX_EXPRESSIONS, newindex_expressions) end
        value = Expression.template(value, false, Object.SET_METHOD_ARGUMENT_NAMES)
        newindex_expressions[index] = value
    elseif special == 'once' then
        local preinit_expressions = rawget(self, recipe_nested.PREINIT_EXPRESSIONS)
        if not preinit_expressions then preinit_expressions = {}; rawset(self, recipe_nested.PREINIT_EXPRESSIONS, preinit_expressions) end
        value = Expression.template(value, true)
        preinit_expressions[index] = value
    else
        local other_values = rawget(self, recipe_nested.OTHER_VALUES)
        if index == 'init' or index == 'update' or index == 'draw' then
            value = Expression.template(value)
        elseif index == 'when' then
            assertf(type(value) == 'table', "On recipe %q: Expected 'when' to be a table, found %q", self[1], type(value))
            for i = 1, #value do
                local t = value[i]
                t[2] = Expression.template(t[2])
            end
        end
        other_values[index] = value
    end
    rawset(self, index, value)
end

function recipe_nested:__pairs()
    return iter_chain(
        self[recipe_nested.NEWINDEX_EXPRESSIONS],
        self[recipe_nested.INDEX_EXPRESSIONS],
        self[recipe_nested.OTHER_VALUES],
        self[recipe_nested.PREINIT_EXPRESSIONS]
    )
end

recipe_nested.__call = Object.new

return recipe_nested