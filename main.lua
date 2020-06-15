require 'globals'

function love.load()
    Resources:loadall('script', 'Circle', 'Scene2')
    
    addtoscene(Scene2())
end

function love.update(dt)
    Director:update(dt)
end

function love.draw()
    Director:draw()
end

function love.mousemoved(x, y, dx, dy, istouch)
    emit { 'mousemoved', x, y, dx, dy, istouch = istouch }
end
function love.mousepressed(x, y, button, istouch, presses)
    emit { 'mousepressed', x, y, button = button, istouch = istouch, presses = presses }
end
function love.mousereleased(x, y, button, istouch, presses)
    emit { 'mousereleased', x, y, button = button, istouch = istouch, presses = presses }
end
function love.wheelmoved(x, y)
    emit { 'wheelmoved', x, y }
end
