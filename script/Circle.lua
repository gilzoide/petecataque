mode = 'fill'
segments = nil
x = 0
y = 0
radius = 10
color = {1, 1, 1}

function init()
    local world = R('world', 'world')
    body = love.physics.newBody(world, x, y, 'dynamic')
    body:setMass(2)
    fixture = love.physics.newFixture(body, love.physics.newCircleShape(radius))
    fixture:setRestitution(0.8)
end

function draw()
    love.graphics.setColor(color)
    love.graphics.circle(mode, body and body:getX() or x, body and body:getY() or y, radius, segments)
end