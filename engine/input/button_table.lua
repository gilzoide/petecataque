local button_table = {}

local EMPTY = { down = false, pressed = false, released = false }
local DOWN = { down = true, pressed = false, released = false }
local PRESSED = { down = true, pressed = true, released = false }
local RELEASED = { down = false, pressed = false, released = true }
button_table.EMPTY = EMPTY
button_table.DOWN = DOWN
button_table.PRESSED = PRESSED
button_table.RELEASED = RELEASED

function button_table.merge_state(a, b)
    if a == EMPTY then
        return b
    elseif b == EMPTY then
        return a
    elseif a.down or b.down then
        if a.pressed and b.pressed then
            return PRESSED
        else
            return DOWN
        end
    elseif a.released and b.released then
        return RELEASED
    else -- one pressed and one released
        return EMPTY
    end
end

function button_table.new()
    return setmetatable({}, button_table)
end

function button_table:pressed(id)
    self[id] = PRESSED
    set_next_frame(self, id, DOWN)
end

function button_table:released(id)
    self[id] = RELEASED
    set_next_frame(self, id, nil)
end

local methods = {
    pressed = button_table.pressed,
    released = button_table.released,
    is_pressed = button_table.is_pressed,
    is_released = button_table.is_released,
    is_down = button_table.is_down,
}
function button_table:__index(index)
    local method = methods[index]
    if method ~= nil then return method end
    return EMPTY
end
button_table.__pairs = default_object_pairs

return button_table
