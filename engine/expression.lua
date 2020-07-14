local Object = require 'object'

local Expression = {}

local loadstring = loadstring or load
local nested_function_evaluate = nested_function.evaluate_with_env
local METHOD_EXPRESSION = 'method'
local GETTER_EXPRESSION = 'getter'

function Expression.is_expression(v)
    return type(v) == 'table' and v.__expression
end

function Expression.is_getter(v)
    return type(v) == 'table' and v.__expression == GETTER_EXPRESSION
end

local function bind_argument_names_to_callable(callable, argument_names)
    return function(expr, ...)
        for i = 1, math.min(#argument_names, select('#', ...)) do
            local name = argument_names[i]
            expr[name] = select(i, ...)
        end
        return callable(expr, ...)
    end
end

local function set_expression_env(expr, env)
    rawset(expr, '__env', env)
end

local function evaluate_nested_expression(expr, self, ...)
    set_expression_env(expr, self)
    return nested_function_evaluate(expr[2], expr, ...)
end

local function call_expression_literal(expr, self, ...)
    return expr[2](self, ...)
end

local function __index_expression(expr, index)
    return index_first_of(index, rawget(expr, '__env'), _ENV)
end

function Expression.from_table(literal, file, line)
    assertf(type(literal) == 'table', "FIXME %s", type(literal))
    local __expression = type(literal[1]) == 'string' and GETTER_EXPRESSION or METHOD_EXPRESSION
    local expr = {
        'Expression', literal,
        __expression = __expression,
        __index = __index_expression,
        __call = evaluate_nested_expression,
        __pairs = Object.__pairs,
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
        set_expression_env(expr, self)
        return setfenv(chunk, expr)(...)
    end
    local expr = {
        'Expression', literal,
        __expression = __expression,
        __index = __index_expression,
        __call = callable,
        __pairs = Object.__pairs,
        __file = file,
        __line = line,
    }
    return setmetatable(expr, expr)
end

function Expression.from_function(f, expression_type)
    local expr = {
        'Expression', literal,
        __expression = expression_type or METHOD_EXPRESSION,
        __index = __index_expression,
        __call = call_expression_literal,
        __pairs = Object.__pairs,
    }
    return setmetatable(expr, expr)
end

function Expression.getter_from_function(f)
    return Expression.from_function(f, GETTER_EXPRESSION)
end

return Expression