local button_table = require 'input.button_table'
local event_listener = require 'input.event_listener'
local gamepad = require 'input.gamepad'

local Input = {
    keycode = button_table.new(),
    scancode = button_table.new(),
    joystick = {},
}

Input.events = {
    keypressed = event_listener.new(),
    keyreleased = event_listener.new(),
    mousemoved = event_listener.new(),
    mousepressed = event_listener.new(),
    mousereleased = event_listener.new(),
    wheelmoved = event_listener.new(),
    joystickadded = event_listener.new(),
    joystickremoved = event_listener.new(),
    gamepadpressed = event_listener.new(),
    gamepadreleased = event_listener.new(),
    gamepadaxis = event_listener.new(),
}

function Input.register_events(obj)
    for k, listener in pairs(Input.events) do
        local callback = obj[k]
        if callback then
            listener:add(obj, callback)
        end
    end
end

function Input.unregister_events(obj)
    for k, listener in pairs(Input.events) do
        listener:remove(obj)
    end
end

-- Keyboard
function Input.keypressed(key, scancode, isrepeat)
    Input.keycode:pressed(key)
    Input.scancode:pressed(scancode)
    Input.events.keypressed(key, scancode, isrepeat)
end

function Input.keyreleased(key, scancode)
    Input.keycode:released(key)
    Input.scancode:released(scancode)
    Input.events.keyreleased(key, scancode)
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
    Input.joystick[joystick:getConnectedIndex()] = gamepad.new()
    Input.events.joystickadded(joystick)
end

function Input.joystickremoved(joystick)
    Input.joystick[joystick:getConnectedIndex()] = nil
    Input.events.joystickremoved(joystick)
end

function Input.gamepadpressed(joystick, button)
    Input.joystick[joystick:getID()]:pressed(button)
    Input.events.gamepadpressed(joystick, button)
end

function Input.gamepadreleased(joystick, button)
    Input.joystick[joystick:getID()]:released(button)
    Input.events.gamepadreleased(joystick, button)
end

function Input.gamepadaxis(joystick, axis, value)
    Input.events.gamepadaxis(joystick, axis, value)
end

return Input
