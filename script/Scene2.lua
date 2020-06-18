-- local child1 = addchild(Rectangle{ x = 60, y = 60 })
-- addchild(Rectangle{ x = 100, y = 200 })

function init()
    background = R('image', 'image/fundo.png')
    world = R('world', 'world', 0, 9.81 * 10)
    body = love.physics.newBody(world)
    floorShape = love.physics.newRectangleShape(400, 590, 800, 20)
    love.physics.newFixture(body, floorShape)
end

function draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background)
    love.graphics.polygon('line', floorShape:getPoints())
end

when = {
    {{ ['Input.mousepressed'] = { button = 1, presses = 1 }}, function()
        local x, y = Input.mousepressed.x, Input.mousepressed.y
        local radius = 10
        local circle = Circle{ x = x, y = y, radius = radius, color = {1, 1, 0} }
        addchild(circle)
    end}
}