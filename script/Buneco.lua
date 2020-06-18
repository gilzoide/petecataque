massa = 10
altura = 80
largura = 40
color = {0, 1, 0}
velocidade = 300

function init()
    local world = R('world', 'world')
    body = love.physics.newBody(world, x, y, 'dynamic')
    body:setMass(massa)
    body:setFixedRotation(true)
    shape = love.physics.newRectangleShape(largura, altura)
    fixture = love.physics.newFixture(body, shape)
    fixture:setFriction(1)
end

function draw()
    love.graphics.setColor(color)
    love.graphics.polygon('fill', body:getWorldPoints(shape:getPoints()))
end

function jump()
    body:applyLinearImpulse(0, -400)
end

when = {
    {{'going_left', '!going_right'}, function()
        local x, y = body:getLinearVelocity()
        body:setLinearVelocity(-velocidade, y)
    end},
    {{'!going_left', 'going_right'}, function()
        local x, y = body:getLinearVelocity()
        body:setLinearVelocity(velocidade, y)
    end},
}