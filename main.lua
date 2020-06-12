require 'globals'

local objects

function love.load()
    objects = {
        ObjectLibrary:instance('rectangle')
    }
end

function love.update(dt)
    EventManager:update(dt)
end

function love.draw()
    EventManager:draw()
end