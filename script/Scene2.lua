-- local child1 = addchild(Rectangle{ x = 60, y = 60 })
-- addchild(Rectangle{ x = 100, y = 200 })

background = background or Resources:get('image', 'image/fundo.png')
world = Resources:get('world', 'world', 0, 9.81 * 10)

function draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background)
end

on('mousepressed', { button = 1, presses = 1 }, function(x, y)
    local radius = 10
    local body = love.physics.newBody(world, x, y, 'dynamic')
    local fixture = love.physics.newFixture(body, love.physics.newCircleShape(radius))
    local circle = Circle{ x = x, y = y, radius = radius, body = body, fixture = fixture, color = {1, 1, 0} }
    addtoscene(circle)
end)