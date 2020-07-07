local Input = {}

-- Keyboard
function Input.keypressed(key, scancode, isrepeat)
    local info = { pressed = true, scancode = scancode, isrepeat = isrepeat }
    _ENV.key[key] = info
    set_next_frame(info, 'pressed', nil)
    if DEBUG and key == 'd' and love.keyboard.isDown('lctrl', 'rctrl') then
        dump_state()
        print()
    end
end

function Input.keyreleased(key, scancode)
    local info = { released = true, scancode = scancode }
    _ENV.key[key] = info
    set_next_frame(_ENV.key, key, nil)
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
