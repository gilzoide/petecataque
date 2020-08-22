local button_table = require 'input.button_table'

local Controller = Recipe.new('Controller')

local function keypressed(self, key, scancode, isrepeat)
    button_table.pressed(self, self.scancode and scancode or key)
end
local function keyreleased(self, key, scancode)
    button_table.released(self, self.scancode and scancode or key)
end

local function gamepadpressed(self, joystick, button)
    if joystick:getConnectedIndex() == self.device then
        button_table.pressed(self, button)
    end
end
local function gamepadreleased(self, joystick, button)
    if joystick:getConnectedIndex() == self.device then
        button_table.released(self, button)
    end
end
local function gamepadaxis(self, axis, value)
    if joystick:getConnectedIndex() == self.device then
        self[axis] = value
    end
end


-- Device 0 is the keyboard, > 0 is the connected gamepads
Controller.device = 0
-- On keyboard, track scancode instead of key code
Controller.scancode = false

Object.add_setter(Controller, 'device', function(self, device)
    if device == 0 then
        Input.events.gamepadpressed:remove(self)
        Input.events.gamepadreleased:remove(self)
        Input.events.gamepadaxis:remove(self)
        Input.events.keypressed:add(self, keypressed)
        Input.events.keyreleased:add(self, keyreleased)
    else
        Input.events.gamepadpressed:add(self, gamepadpressed)
        Input.events.gamepadreleased:add(self, gamepadreleased)
        Input.events.gamepadaxis:add(self, gamepadaxis)
        Input.events.keypressed:remove(self)
        Input.events.keyreleased:remove(self)
    end
end)

function Controller:button_to_axis(a, b)
    local negative = (self[a] or button_table.EMPTY).down and 1 or 0
    local positive = (self[b] or button_table.EMPTY).down and 1 or 0
    return positive - negative
end

return Controller
