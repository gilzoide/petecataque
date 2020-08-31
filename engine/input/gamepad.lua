local button_table = require 'input.button_table'

local gamepad = {}

function gamepad.new()
    return setmetatable({
        connected = true,
        leftx = 0,
        lefty = 0,
        rightx = 0,
        righty = 0,
        triggerleft = 0,
        triggerright = 0,
    }, gamepad)
end

gamepad.pressed = button_table.pressed
gamepad.released = button_table.released
function gamepad:axis(id, value)
    self[id] = value
end


local methods = {
    pressed = gamepad.pressed,
    released = gamepad.released,
    axis = gamepad.axis,
}
function gamepad:__index(index)
    return methods[index] or button_table.EMPTY
end

return gamepad
