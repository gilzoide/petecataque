require 'globals'

local objects

function love.load()
    ObjectLibrary:load('Rectangle')
    ObjectLibrary:load('Square')
    
    objects = {
        Rectangle(),
        Square(),
    }
end

function love.update(dt)
    EventManager:update(dt)
end

function love.draw()
    EventManager:draw()
end