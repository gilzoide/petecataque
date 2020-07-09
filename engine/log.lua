local log = {}

if DEBUG.enabled then 
    function log.warnassert(cond, fmt, ...)
        if not cond and fmt then
            print('WARNING: ' .. string.format(fmt, ...))
        end
        return cond, fmt, ...
    end
else
    function log.warnassert(...)
        return ...
    end
end

return log