local button_table = require 'input.button_table'
local gamepad = require 'input.gamepad'

local Input = {
    keycode = button_table.new(),
    scancode = button_table.new(),
    joystick = {},
}

-- Keyboard
function Input.keypressed(key, scancode, isrepeat)
    Input.keycode:pressed(key)
    Input.scancode:pressed(scancode)
end

function Input.keyreleased(key, scancode)
    Input.keycode:released(key)
    Input.scancode:released(scancode)
end

-- Mouse
function Input.mousemoved(x, y, dx, dy, istouch)
    _ENV.mouse.moved = { x = x, y = y, dx = dx, dy = dy, istouch = istouch }
    _ENV.mouse.position = { x, y }
    set_next_frame(_ENV.mouse, 'moved', nil)
end

function Input.mousepressed(x, y, button, istouch, presses)
    local info = { pressed = true, x = x, y = y, istouch = istouch, presses = presses }
    _ENV.mouse[button] = info
    set_next_frame(info, 'pressed', nil)
end

function Input.mousereleased(x, y, button, istouch, presses)
    local info = { released = true, x = x, y = y, istouch = istouch, presses = presses }
    _ENV.mouse[button] = info
    set_next_frame(_ENV.mouse, button, nil)
end

function Input.wheelmoved(x, y)
    _ENV.mouse.wheelmoved = { x = x, y = y }
    set_next_frame(_ENV.mouse, 'wheelmoved', nil)
end

-- Gamepad
function Input.joystickadded(joystick)
    Input.joystick[joystick:getID()] = gamepad.new()
end

function Input.joystickremoved(joystick)
    Input.joystick[joystick:getID()].connected = false
end

function Input.gamepadpressed(joystick, button)
    Input.joystick[joystick:getID()]:pressed(button)
end

function Input.gamepadreleased(joystick, button)
    Input.joystick[joystick:getID()]:released(button)
end

return Input
