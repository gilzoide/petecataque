local debug = {}

function debug.fassert(cond, fmt, ...)
    return assert(cond, string.format(fmt, ...))
end

function debug.warn(fmt, ...)
    print("WARNING: " .. string.format(fmt, ...))
end

return debug