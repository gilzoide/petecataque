unpack = unpack or table.unpack
function rawpairs(t)
    return next, t, nil
end
function pairs(t)
    local mt = getmetatable(t)
    return (mt and mt.__pairs or rawpairs)(t)
end
function default_object_pairs(self)
    return coroutine.wrap(function()
        for k, v in rawpairs(self) do
            if type(k) == 'string' then
                if k:startswith('__') then
                    k = nil
                elseif k:startswith('_') then
                    k = k:sub(2)
                end
            end
            if k then coroutine.yield(k, v) end
        end
    end)
end
do
    local success, m = pcall(require, 'DEBUG')  -- DEBUG is excluded on release
    DEBUG = success and m or setmetatable({ enabled = false }, require 'empty')
    assert(DEBUG.enabled ~= nil, "FIXME")
end
nested = require 'nested'
nested_function = require 'nested.function'
nested_ordered = require 'nested.ordered'
nested_match = require 'nested.match'

function assertf(cond, fmt, ...)
    return assert(cond, string.format(fmt, ...))
end

function errorf(fmt, ...)
    return error(string.format(fmt, ...))
end

Expression = require 'expression'
Object = require 'object'
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

function index_first_of(index, ...)
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        if t then
            local value = t[index]
            if value ~= nil then return value end
        end
    end
    return nil
end
function rawindex_first_of(index, ...)
    for i = 1, select('#', ...) do
        local t = select(i, ...)
        if t then
            local value = rawget(t, index)
            if value ~= nil then return value end
        end
    end
    return nil
end
function create_index_first_of(index_chain)
    return index_chain and function(t, index)
        return index_first_of(index, unpack(index_chain))
    end
end

function safeunpack(v, i, j)
    if type(v) == 'table' then
        return unpack(v, i, j)
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
function string.endswith(s, suffix)
    return s:sub(- #suffix) == suffix
end

function table_extend(t, other)
    if other then
        local n = #t
        for i, v in ipairs(other) do
            t[n + i] = v
        end
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

function shallowcopy(value)
    if type(value) == 'table' then
        local newvalue = {}
        for k, v in pairs(value) do
            newvalue[k] = v
        end
        return newvalue
    else
        return value
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

function iscallable(v)
    if type(v) == 'function' then
        return true
    else
        local mt = getmetatable(v)
        return mt and mt.__call
    end
end

keyboard = {}
mouse = {
    position = { love.mouse.getPosition() }
}
Input = require 'input'

Scene = require 'scene'.new()
InvokeQueue = require 'invoke_queue'.new()
Director = require 'director'
Resources = require 'resources'.new()
R = Resources
State = {
    scene = Scene,
    resources = Resources,
    key = key,
    mouse = mouse,
    invoke_queue = InvokeQueue,
}

function dump_state()
    local s = nested.encode(Scene)
    if DEBUG.enabled then
        s = s .. '\n\n' .. nested.encode(DEBUG.scene)
    end
    print(s, '\n')
    love.system.setClipboardText(s)
end

function set_after_frames(n, ...)
    InvokeQueue:queue_after(n, set, ...)
end
function set_next_frame(...)
    set_after_frames(1, ...)
end
