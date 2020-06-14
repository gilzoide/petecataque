lfs = love.filesystem
unpack = unpack or table.unpack
debug_log = require 'debug_log'

Director = require 'director'.new()
ObjectLibrary = require 'object_library'.new():register_love()

function is_type(obj, ...)
    local t = type(obj)
    for _, v in ipairs{...} do
        if t == v then return true end
    end
    return false
end

function assertf(cond, fmt, ...)
    return assert(cond, string.format(fmt, ...))
end

function errorf(fmt, ...)
    return error(string.format(fmt, ...))
end

function deg2rad(angle)
    return angle * math.pi / 180
end
function rad2deg(angle)
    return angle * 180 / math.pi
end
