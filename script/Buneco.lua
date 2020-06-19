massa = 10
raio = 25
largura_raquete = 10
altura_raquete = raio * 4
cor = {1, 1, 1}
cor_dano = {1, 0, 0}
cor_raquete = {0, 1, 1}
velocidade_angular = 8

function init()
    local world = R('world', 'world')
    body = love.physics.newBody(world, x, y, 'dynamic')
    body:setMass(massa)
    body:setAngularDamping(1)
    main_shape = love.physics.newCircleShape(raio)
    main_fixture = love.physics.newFixture(body, main_shape, 5)
    local raquete_x_factor = flipX and -1 or 1
    local raquete_x = raquete_x_factor * (altura_raquete * 0.5 + raio * 0.5)
    raquete_shape = love.physics.newRectangleShape(raquete_x, 0, largura_raquete, altura_raquete, math.pi / 2)
    raquete_fixture = love.physics.newFixture(body, raquete_shape)
    raquete_fixture:setFriction(1)
end

function draw()
    love.graphics.setColor(tomou_dano and cor_dano or cor)
    local x, y = body:getWorldPoint(main_shape:getPoint())
    love.graphics.circle('fill', x, y, main_shape:getRadius())
    love.graphics.setColor(cor_raquete)
    love.graphics.polygon('fill', body:getWorldPoints(raquete_shape:getPoints()))
end

when = {
    {{'going_left', '!going_right'}, function()
        body:setAngularVelocity(-velocidade_angular)
    end},
    {{'!going_left', 'going_right'}, function()
        body:setAngularVelocity(velocidade_angular)
    end},
}