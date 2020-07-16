local Expression = {}

local loadstring = loadstring or load
local nested_function_evaluate = nested_function.evaluate_with_env
local METHOD_EXPRESSION = 'method'
local GETTER_EXPRESSION = 'getter'
local ARGUMENT_NAMES_KEY = 'argument_names'

function Expression.is_expression(v)
    return type(v) == 'table' and v.__expression
end

function Expression.is_getter(v)
    return type(v) == 'table' and v.__expression == GETTER_EXPRESSION
end

function Expression.bind_argument_names(expr, argument_names)
    if not Expression.is_expression(expr) then return end
    assertf(type(argument_names) == 'table', "Expected argument_names as table, found %q", type(argument_names))
    expr[ARGUMENT_NAMES_KEY] = argument_names
end

local function setup_expression_call(expr, self, ...)
    rawset(expr, '__env', self)
    local argument_names = expr[ARGUMENT_NAMES_KEY]
    if argument_names then
        for i = 1, math.min(#argument_names, select('#', ...)) do
            local name = argument_names[i]
            rawset(expr, name, (select(i, ...)))
        end
    end
end

local function evaluate_nested_expression(expr, self, ...)
    setup_expression_call(expr, self, ...)
    return nested_function_evaluate(expr[2], expr, self, ...)
end

local function call_expression_literal(expr, self, ...)
    return expr[2](self, ...)
end

local function __index_expression(expr, index)
    return index_first_of(index, rawget(expr, '__env'), _ENV)
end

function Expression.from_table(literal, file, line)
    assertf(type(literal) == 'table', "FIXME %s", type(literal))
    local __expression = literal[1] == 'R' and GETTER_EXPRESSION or METHOD_EXPRESSION
    local expr = {
        'Expression', literal,
        __expression = __expression,
        __index = __index_expression,
        __call = evaluate_nested_expression,
        __pairs = default_object_pairs,
        __file = file,
        __line = line,
    }
    return setmetatable(expr, expr)
end

function Expression.from_string(literal, file, line)
    assertf(type(literal) == 'string', "FIXME %s", type(literal))
    local __expression = METHOD_EXPRESSION
    if not literal:match("^%s*do") then
        literal = 'return ' .. literal
        __expression = GETTER_EXPRESSION
    end
    local chunk = assert(loadstring(literal, string.format("%s:%s", file, line)))
    local callable = function(expr, self, ...)
        setup_expression_call(expr, self, ...)
        return setfenv(chunk, expr)(self, ...)
    end
    local expr = {
        'Expression', literal,
        __expression = __expression,
        __index = __index_expression,
        __call = callable,
        __pairs = default_object_pairs,
        __file = file,
        __line = line,
    }
    return setmetatable(expr, expr)
end

function Expression.from_function(literal, expression_type)
    assertf(type(literal) == 'function', "FIXME %s", type(literal))
    local expr = {
        'Expression', literal,
        __expression = expression_type or METHOD_EXPRESSION,
        __index = __index_expression,
        __call = call_expression_literal,
        __pairs = default_object_pairs,
    }
    return setmetatable(expr, expr)
end

function Expression.getter_from_function(f)
    return Expression.from_function(f, GETTER_EXPRESSION)
end

return Expression