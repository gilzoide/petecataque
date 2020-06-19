gravidade = 9.81 * METER_BY_PIXEL
paredes = {
    0, WINDOW_HEIGHT,
    0, 0,
    WINDOW_WIDTH, 0,
    WINDOW_WIDTH, WINDOW_HEIGHT,
}
chao = {
    0, WINDOW_HEIGHT,
    WINDOW_WIDTH, WINDOW_HEIGHT,
}
peteca_init_x = WINDOW_WIDTH * 0.5
peteca_init_y = 100


function init()
    background = R('image', 'image/fundo.png')
    world = R('world', 'world', 0, gravidade)
    body = love.physics.newBody(world)
    paredes_shape = love.physics.newChainShape(false, unpack(paredes))
    paredes_fixture = love.physics.newFixture(body, paredes_shape)
    paredes_fixture:setFriction(1)
    chao_shape = love.physics.newEdgeShape(unpack(chao))
    chao_fixture = love.physics.newFixture(body, chao_shape)
    chao_fixture:setFriction(1)
    
    peteca = Peteca { x = peteca_init_x, y = peteca_init_y }
    buneco1 = Buneco { x = WINDOW_WIDTH * 0.25, y = WINDOW_HEIGHT - Buneco.raio }
    buneco2 = Buneco { x = WINDOW_WIDTH * 0.75, y = WINDOW_HEIGHT - Buneco.raio, cor = {0, 0, 1}, flipX = true }
    addchild(peteca)
    addchild(buneco1)
    addchild(buneco2)
end

function reset_peteca()
    peteca.body:setPosition(peteca_init_x, peteca_init_y)
    peteca.body:setAngle(0)
    peteca.body:setAngularVelocity(0)
    peteca.body:setLinearVelocity(0, 0.1)
end

when = {
    {{ 'Input.keypressed.r' }, function()
        reset_peteca()
    end},
    {{ 'Input.keypressed.left' }, function()
        buneco1.going_left = true
    end},
    {{ 'Input.keyreleased.left' }, function()
        buneco1.going_left = false
    end},
    {{ 'Input.keypressed.right' }, function()
        buneco1.going_right = true
    end},
    {{ 'Input.keyreleased.right' }, function()
        buneco1.going_right = false
    end},
    {{ 'Input.keypressed.a' }, function()
        buneco2.going_left = true
    end},
    {{ 'Input.keyreleased.a' }, function()
        buneco2.going_left = false
    end},
    {{ 'Input.keypressed.d' }, function()
        buneco2.going_right = true
    end},
    {{ 'Input.keyreleased.d' }, function()
        buneco2.going_right = false
    end},
    {{}, function()
        local collinfo = nested.get(Collisions, 'postSolve', buneco1.raquete_fixture, peteca.fixture)
            or nested.get(Collisions, 'postSolve', buneco2.raquete_fixture, peteca.fixture)
        if collinfo then
            peteca.impulso(collinfo)
        end
    end}
}