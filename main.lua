local Input = require 'input'

function love.load(arg)
    require 'globals'
    DEBUG.LOAD(arg)
    
    local initial_scene = arg[1] or 'PetecaScene'
    local scene = assert(R(initial_scene))()
    addtoscene(scene)

end

function love.update(dt)
    TIME = TIME + dt
    Director.update(dt)
    DEBUG.UPDATE(dt)
end

function love.draw()
    InvokeQueue:flip()
    DEBUG.PREDRAW()
    Director.draw()
    DEBUG.DRAW()
    InvokeQueue:frame_ended()
end

function love.quit()
    Scene:release()
end

love.mousemoved = Input.mousemoved
love.mousepressed = Input.mousepressed
love.mousereleased = Input.mousereleased
love.wheelmoved = Input.wheelmoved

love.keypressed = Input.keypressed
love.keyreleased = Input.keyreleased

love.joystickadded = Input.joystickadded
love.joystickremoved = Input.joystickremoved
love.gamepadpressed = Input.gamepadpressed
love.gamepadreleased = Input.gamepadreleased
