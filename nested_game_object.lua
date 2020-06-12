local nested = require 'lib.nested'

local nested_game_object = {}

function nested_game_object.from_table(t)
end

function nested_game_object.loadfile(filename)
    local t = assert(nested.decode_file(filename))
    return nested_game_object.from_table(t)
end

return nested_game_object