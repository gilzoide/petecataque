base = 30
altura_base = 20
massa = 1
color = {1, 1, 0}

function init()
    local world = R('world', 'world')
    body = love.physics.newBody(world, x, y, 'dynamic')
    body:setMass(massa)
    body:setAngularDamping(1)
    base_shape_points = {
        -base * 0.5, 0,
        -base * 0.5, -altura_base * 0.5,
        -base * 0.25, -altura_base * 0.5,
        -base * 0.25, -altura_base,
        base * 0.25, -altura_base,
        base * 0.25, -altura_base * 0.5,
        base * 0.5, -altura_base * 0.5,
        base * 0.5, 0,
    }
    base_shape = love.physics.newPolygonShape(base_shape_points)
    pena_shape = love.physics.newPolygonShape(
        0, -altura_base,
        -base * 0.25, -altura_base * 4,
        base * 0.25, -altura_base * 4
    )
    fixture = love.physics.newFixture(body, base_shape)
    fixture:setRestitution(0.1)
    love.physics.newFixture(body, pena_shape)
end

function draw()
    love.graphics.setColor(color)
    love.graphics.polygon('line', body:getWorldPoints(pena_shape:getPoints()))
    love.graphics.polygon('line', body:getWorldPoints(unpack(base_shape_points)))
end

function impulso(coll)
    local nx, ny = coll.coll:getNormal()
    if ny > 0 then ny = -ny end
    nx = nx * coll.normalimpulse
    ny = ny * coll.normalimpulse
    body:applyLinearImpulse(nx, ny)
end
