require 'globals'

function love.load()
    -- Resources:loadall('script', 'Circle', 'Scene2')
    Resources:loadall('script', 'Peteca', 'Buneco', 'CenaPeteca')
    
    -- R('tree', 'script/Scene2.nested')
    local scene = CenaPeteca()
    addtoscene(scene)
end

function love.update(dt)
    Resources:update(dt) -- Worlds
    Director:update(dt)  -- Scene and events
    Input = {}
end

function love.draw()
    Director:draw()
end

function love.mousemoved(x, y, dx, dy, istouch)
    emit { 'mousemoved', x, y, dx, dy, istouch = istouch }
end
function love.mousepressed(x, y, button, istouch, presses)
    Input.mousepressed = { x = x, y = y, button = button, istouch = istouch, presses = presses }
end
function love.mousereleased(x, y, button, istouch, presses)
    emit { 'mousereleased', x, y, button = button, istouch = istouch, presses = presses }
end
function love.wheelmoved(x, y)
    emit { 'wheelmoved', x, y }
end

function love.keypressed(key, scancode, isrepeat)
    Input.keypressed = { key = key, scancode = scancode, isrepeat = isrepeat }
    if key == 'd' and love.keyboard.isDown('lctrl', 'rctrl') then
        dump_state()
        print()
    end
end
function love.keyreleased(key, scancode)
    Input.keyreleased = { key = key, scancode = scancode }
end
