local debug_log = {}

function debug_log.info(fmt, ...)
    print("INFO: " .. string.format(fmt, ...))
end

function debug_log.warn(fmt, ...)
    print("WARNING: " .. string.format(fmt, ...))
end

return debug_log