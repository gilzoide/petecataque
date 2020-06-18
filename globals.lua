lfs = love.filesystem
unpack = unpack or table.unpack
loadstring = loadstring or load
nested = require 'nested'
nested_function = require 'nested.function'
nested_match = require 'nested.match'

function is_type(obj, ...)
    local t = type(obj)
    for _, v in ipairs{...} do
        if t == v then return true end
    end
    return false
end

function on(event_pattern, handler)
    local self = getfenv(2)
    if type(handler) == 'string' then
        handler = setfenv(assert(loadstring(handler)), self)
    end
    if event_pattern == 'draw' or event_pattern == 'update' then
        self[event_pattern] = handler
    else
        if type(event_pattern) ~= 'table' then event_pattern = { event_pattern } end
        Director:register(event_pattern, handler)
    end
end
function emit(...)
    Director:queue_event(...)
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
    return obj
end
function addtoscene(obj)
    Scene[#Scene + 1] = obj
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

function is_callable(v)
    local vtype = type(v)
    if vtype == 'table' then
        local mt = getmetatable(v)
        return mt and type(mt.__call) == 'function'
    else
        return vtype == 'function'
    end
end

Input = {}
Scene = {}
Director = require 'director'.new()
Resources = require 'resources'.new()
State = {
    scene = Scene,
    resources = Resources,
    director = Director,
    input = Input,
}

function dump_state()
    print(nested.encode(State))
end

function R(...)
    return Resources:get(...)
end