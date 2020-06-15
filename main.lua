require 'globals'

function love.load()
    ObjectLibrary:load('Node2D')
    ObjectLibrary:load('Rectangle')
    ObjectLibrary:load('Scene1')
    ObjectLibrary:load('Scene2')
    ObjectLibrary:load('Circle')

    State:add_toplevel(Scene2())
end

function love.update(dt)
    State:apply()
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
