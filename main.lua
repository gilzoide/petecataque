require 'globals'

local objects

function love.load()
    objects = {
        ObjectLibrary:instance('Rectangle'),
        ObjectLibrary:instance('Square'),
    }
end

function love.update(dt)
    EventManager:update(dt)
end

function love.draw()
    EventManager:draw()
end