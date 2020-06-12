lfs = love.filesystem
unpack = unpack or table.unpack
debug_log = require 'debug_log'

EventManager = require 'event_manager'.new()
ObjectLibrary = require 'object_library'.new()

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
    return error(string.format(error, ...))
end
