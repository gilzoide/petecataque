local button_table = require 'input.button_table'

local gamepad = {}

function gamepad.new()
    return setmetatable({
        connected = true,
        button = button_table.new(),
    }, gamepad)
end

function gamepad:pressed(id)
    self.button:pressed(id)
end

function gamepad:released(id)
    self.button:released(id)
end

local methods = {
    pressed = gamepad.pressed,
    released = gamepad.released,
}
gamepad.__index = methods

return gamepad
