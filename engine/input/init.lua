local button_or_axis_table = require 'input.button_or_axis_table'

local Input = {
    key = button_or_axis_table.new(),
    scancode = button_or_axis_table.new(),
}

-- Keyboard
function Input.keypressed(key, scancode, isrepeat)
    Input.key:pressed(key)
    Input.scancode:pressed(scancode)
end

function Input.keyreleased(key, scancode)
    Input.key:released(key)
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

return Input
