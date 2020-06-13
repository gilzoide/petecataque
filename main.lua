require 'globals'

local objects

function love.load()
    ObjectLibrary:load('Node2D')
    ObjectLibrary:load('Rectangle')
    ObjectLibrary:load('Square')
    ObjectLibrary:load('Scene1')

    objects = {
        Scene1(),
    }
end

function love.update(dt)
    EventManager:update(dt)
end

function love.draw()
    EventManager:draw()
end