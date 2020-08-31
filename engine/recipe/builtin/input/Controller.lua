local button_table = require 'input.button_table'

local Controller = Recipe.new('Controller')

-- Device 0 is the keyboard, > 0 is the connected gamepads
Controller.device_index = 0
-- On keyboard, track scancode instead of key code
Controller.scancode = false

Controller:add_getter('device', function(self)
    local device_index = self.device_index
    if device_index == 0 then
        return self.scancode and Input.scancode or Input.keycode
    else
        return Input.joystick[device_index]
    end
end)

return Controller
