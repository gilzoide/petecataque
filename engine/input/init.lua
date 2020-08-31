local button_table = require 'input.button_table'
local event_listener = require 'input.event_listener'
local gamepad = require 'input.gamepad'
local mouse = require 'input.mouse'

local Input = {
    keycode = button_table.new(),
    scancode = button_table.new(),
    joystick = {},
    mouse = mouse.new(),
}

Input.events = {
    keypressed = event_listener.new('keypressed'),
    keyreleased = event_listener.new('keyreleased'),
    mousemoved = event_listener.new('mousemoved'),
    mousepressed = event_listener.new('mousepressed'),
    mousereleased = event_listener.new('mousereleased'),
    wheelmoved = event_listener.new('wheelmoved'),
    joystickadded = event_listener.new('joystickadded'),
    joystickremoved = event_listener.new('joystickremoved'),
    gamepadpressed = event_listener.new('gamepadpressed'),
    gamepadreleased = event_listener.new('gamepadreleased'),
    gamepadaxis = event_listener.new('gamepadaxis'),
}

function Input.register_events(obj)
    local recipe = rawget(obj, '__recipe')
    for k, listener in pairs(Input.events) do
        local callback = recipe[k]
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
    Input.mouse:moved(x, y, dx, dy, istouch)
    Input.events.mousemoved(x, y, dx, dy, istouch)
end

function Input.mousepressed(x, y, button, istouch, presses)
    Input.mouse:pressed(x, y, button, istouch, presses)
    Input.events.mousepressed(x, y, button, istouch, presses)
end

function Input.mousereleased(x, y, button, istouch, presses)
    Input.mouse:released(x, y, button, istouch, presses)
    Input.events.mousereleased(x, y, button, istouch, presses)
end

function Input.wheelmoved(x, y)
    Input.mouse:wheelmoved(x, y)
    Input.events.wheelmoved(x, y)
end

-- Gamepad
function Input.joystickadded(joystick)
    Input.joystick[joystick:getID()] = gamepad.new()
    Input.events.joystickadded(joystick)
end

function Input.joystickremoved(joystick)
    Input.joystick[joystick:getID()] = nil
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
    Input.joystick[joystick:getID()]:axis(axis, value)
    Input.events.gamepadaxis(joystick, axis, value)
end

return Input
