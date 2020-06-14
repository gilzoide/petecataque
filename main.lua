require 'globals'

function love.load()
    ObjectLibrary:load('Node2D')
    ObjectLibrary:load('Rectangle')
    ObjectLibrary:load('Scene1')

    Scene1()
end

function love.update(dt)
    Director:update(dt)
end

function love.draw()
    Director:draw()
end