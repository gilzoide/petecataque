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

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        State:add_toplevel(Circle{ x = x, y = y, })
    end
end
