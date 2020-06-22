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

function love.mousemoved(x, y, dx, dy, istouch)
    Input.mousemoved = { x = x, y = y, dx = dx, dy = dy, istouch = istouch }
end
function love.mousepressed(x, y, button, istouch, presses)
    Input.mousepressed = { x = x, y = y, button = button, istouch = istouch, presses = presses }
end
function love.mousereleased(x, y, button, istouch, presses)
    Input.mousereleased = { x = x, y = y, button = button, istouch = istouch, presses = presses }
end
function love.wheelmoved(x, y)
    Input.wheelmoved = { x = x, y = y }
end

love.keypressed = Input.keypressed
love.keyreleased = Input.keyreleased
