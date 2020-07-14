unpack = unpack or table.unpack
function rawpairs(t)
    return next, t, nil
end
function pairs(t)
    local mt = getmetatable(t)
    return (mt and mt.__pairs or rawpairs)(t)
end
do
    local success, m = pcall(require, 'DEBUG')  -- DEBUG is excluded on release
    DEBUG = success and m or setmetatable({ enabled = false }, require 'empty')
    assert(DEBUG.enabled ~= nil, "FIXME")
end
nested = require 'nested'
nested_function = require 'nested.function'
nested_match = require 'nested.match'
log = require 'log'
Expression = require 'expression'
Recipe = require 'recipe'
_ENV = _ENV or getfenv()

METER_BY_PIXEL = 60
love.physics.setMeter(METER_BY_PIXEL)

get = nested.get
get_or_create = nested.get_or_create
set = nested.set
set_or_create = nested.set_or_create
function unset(obj, ...)
    local kp = select('#', ...) > 1 and {...} or ...
    set(obj, kp, nil)
end

function index_first_of(index, index_chain)
    for i = 1, #index_chain do
        local t = index_chain[i]
        if t then
            local value = t[index]
            if value ~= nil then return value end
        end
    end
    return nil
end
function create_index_first_of(index_chain)
    return index_chain and function(t, index)
        return index_first_of(index, index_chain)
    end
end

function safeunpack(v)
    if type(v) == 'table' then
        return unpack(v)
    elseif v ~= nil then
        return v
    end
    -- if v == nil, don't return any values
end
function safepack(...)
    if select('#', ...) > 1 then
        return {...}
    else
        return ...
    end
end

function string.startswith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

function table_extend(t, ...)
    for i = 1, select('#', ...) do
        t[#t + 1] = select(i, ...)
    end
    return t
end

function index_or_create(t, index)
    local value = t[index]
    if value == nil then
        value = {}
        t[index] = value
    end
    return value
end

function addchild(obj)
    local self = getfenv(2)
    self[#self + 1] = obj
    Scene:track(obj)
    return obj
end
function addtoscene(obj)
    Scene:add(obj)
end

function assertf(cond, fmt, ...)
    return assert(cond, string.format(fmt, ...))
end

function errorf(fmt, ...)
    return error(string.format(fmt, ...))
end

function clamp(x, min, max)
    if x < min then return min
    elseif x > max then return max
    else return x
    end
end

function deg2rad(angle)
    return angle * math.pi / 180
end
function rad2deg(angle)
    return angle * 180 / math.pi
end

function bind(f, ...)
    local bound_args = {...}
    return function(...)
        local args = {}
        for i = 1, #bound_args do args[i] = bound_args[i] end
        table_extend(args, ...)
        return f(unpack(args))
    end
end

function deepcopy(value)
    if type(value) == 'table' then
        local newvalue = {}
        for k, v in pairs(value) do
            newvalue[k] = deepcopy(v)
        end
        return newvalue
    else
        return value
    end
end

function iter_chain(...)
    local n = select('#', ...)
    local chain = {...}
    return coroutine.wrap(function()
        for i = 1, n do
            local t = chain[i]
            if t then
                for k, v in pairs(t) do coroutine.yield(k, v) end
            end
        end
    end)
end

function print_nested(...)
    local t = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        t[i] = nested.encode(v)
    end
    print(unpack(t))
    print()
end

key = {}
mouse = {
    position = {0, 0}
}
Input = require 'input'

Scene = require 'scene'.new()
Setqueue = require 'setqueue'.new()
Director = require 'director'
Resources = require 'resources'.new()
R = Resources
State = {
    scene = Scene,
    resources = Resources,
    key = key,
    mouse = mouse,
    setqueue = Setqueue,
}

function dump_state()
    local s = nested.encode(State)
    print(s, '\n')
    love.system.setClipboardText(s)
end

function set_next_frame(...)
    Setqueue:queue(...)
end
