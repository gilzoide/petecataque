require 'globals'

function love.load()
    Resources:loadall('script', 'Peteca', 'Buneco', 'Vida', 'Placar', 'CenaPeteca')

    local scene = CenaPeteca()
    addtoscene(scene)
end

function love.update(dt)
    _ENV.dt = dt
    Director:update(dt)
    Collisions:reset()
end

function love.draw()
    Director:draw()
    Setqueue:update()
end

love.mousemoved = Input.mousemoved
love.mousepressed = Input.mousepressed
love.mousereleased = Input.mousereleased
love.wheelmoved = Input.wheelmoved

love.keypressed = Input.keypressed
love.keyreleased = Input.keyreleased
