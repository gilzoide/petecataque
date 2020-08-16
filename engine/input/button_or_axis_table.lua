local button_or_axis_table = {}

function button_or_axis_table.new()
    return setmetatable({
        _pressed = {},
        _value = {}, -- from -1 to 1 on axes, always 1 for buttons
        _released = {},
    }, button_or_axis_table)
end

function button_or_axis_table:pressed(id, value)
    self._value[id] = value or 1
    self._pressed[id] = true
    set_next_frame(self._pressed, id, nil)
end

function button_or_axis_table:released(id)
    self._value[id] = nil
    self._released[id] = true
    set_next_frame(self._released, id, nil)
end

function button_or_axis_table:is_pressed(...)
    local is_pressed = false
    for i = 1, select('#', ...) do
        local key = select(i, ...)
        if self._pressed[key] then
            is_pressed = true
        elseif self._value[key] then
            return false
        end
    end
    return is_pressed
end

function button_or_axis_table:is_released(...)
    local is_released = false
    for i = 1, select('#', ...) do
        local key = select(i, ...)
        if self._released[key] then
            is_released = true
        elseif self._value[key] then
            return false
        end
    end
    return is_released
end

function button_or_axis_table:is_down(...)
    for i = 1, select('#', ...) do
        local key = select(i, ...)
        if self._value[key] then
            return true
        end
    end
    return false
end

button_or_axis_table.__index = {
    pressed = button_or_axis_table.pressed,
    released = button_or_axis_table.released,
    is_pressed = button_or_axis_table.is_pressed,
    is_released = button_or_axis_table.is_released,
    is_down = button_or_axis_table.is_down,
}
button_or_axis_table.__pairs = default_object_pairs

return button_or_axis_table
