lfs = love.filesystem
tiny = require 'lib.tiny'
unpack = unpack or table.unpack

function knext(t, index)
    local value
    repeat
        index, value = next(t, index)
    until type(index) ~= 'number'
    return index, value
end
function kpairs(t)
    return knext, t, nil
end
