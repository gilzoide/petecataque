require 'globals'

function love.load()
    -- Resources:loadall('script', 'Peteca', 'Buneco', 'Vida', 'Placar', 'CenaPeteca')
    -- local scene = CenaPeteca()
    -- addtoscene(scene)
    
    local scene = R.recipe.Cena2 { id = 'root' }
    addtoscene(scene)

    -- print(nested.encode(scene))
end

_ENV.TIME = 0
function love.update(dt)
    _ENV.dt = dt
    _ENV.TIME = _ENV.TIME + dt
    Setqueue:update(dt)
    Director.update(dt)
    Collisions:reset()
end

function love.draw()
    Setqueue:flip()
    Director.draw()
    Setqueue:frame_ended()
end

love.mousemoved = Input.mousemoved
love.mousepressed = Input.mousepressed
love.mousereleased = Input.mousereleased
love.wheelmoved = Input.wheelmoved

love.keypressed = Input.keypressed
love.keyreleased = Input.keyreleased
