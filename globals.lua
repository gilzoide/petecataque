lfs = love.filesystem
unpack = unpack or table.unpack
loadstring = loadstring or load
nested = require 'nested'
nested_function = require 'nested.function'
nested_match = require 'nested.match'
denver = require 'denver'

METER_BY_PIXEL = 60
love.physics.setMeter(METER_BY_PIXEL)
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

function is_type(obj, ...)
    local t = type(obj)
    for _, v in ipairs{...} do
        if t == v then return true end
    end
    return false
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

function bind(f, ...)
    local bound_args = {...}
    return function(...)
        local args = {}
        for i = 1, #bound_args do args[i] = bound_args[i] end
        for i = 1, select('#', ...) do args[#args + 1] = select(i, ...) end
        return f(unpack(args))
    end
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

Scene = {}
Input = require 'input'.new()
Collisions = require 'collisions'.new()
Director = require 'director'.new()
Resources = require 'resources'.new()
State = {
    scene = Scene,
    resources = Resources,
    director = Director,
    input = Input,
    collisions = Collisions,
}

function dump_state()
    print(nested.encode(State))
end

function R(...)
    return Resources:get(...)
end