local log = {}

if DEBUG then 
    function log.warnassert(cond, fmt, ...)
        if not cond then
            print('WARNING: ' .. string.format(fmt, ...))
        end
        return cond
    end
else
    function log.warnassert(cond, fmt, ...)
        return cond
    end
end

return log