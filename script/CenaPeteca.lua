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

buneco1_x = WINDOW_WIDTH * 0.25
buneco2_x = WINDOW_WIDTH * 0.75
buneco_y = WINDOW_HEIGHT - Buneco.raio


function init()
    esperando = true

    background = R('image', 'image/fundo.png')
    world = R('world', 'world', 0, gravidade)
    body = love.physics.newBody(world)
    paredes_shape = love.physics.newChainShape(false, unpack(paredes))
    paredes_fixture = love.physics.newFixture(body, paredes_shape)
    paredes_fixture:setFriction(1)
    chao_shape = love.physics.newEdgeShape(unpack(chao))
    chao_fixture = love.physics.newFixture(body, chao_shape)
    chao_fixture:setFriction(1)
    
    buneco1 = addchild(Buneco { x = buneco1_x, y = buneco_y, cor = {0, 1, 0} })
    buneco2 = addchild(Buneco { x = buneco2_x, y = buneco_y, cor = {0, 0, 1}, flipX = true })
    vida1 = addchild(Vida { cor = buneco1.cor })
    vida2 = addchild(Vida { cor = buneco2.cor, flipX = true })
    peteca = addchild(Peteca { x = peteca_init_x, y = peteca_init_y })
    placar = addchild(Placar {})

    also_when = {
        {{ { 'Collisions', 'postSolve', peteca.fixture, buneco1.raquete_fixture } }, function()
            local collinfo = nested.get(Collisions, 'postSolve', peteca.fixture, buneco1.raquete_fixture)
            peteca.impulso(collinfo)
        end},
        {{ { 'Collisions', 'touching', peteca.fixture, buneco1.main_fixture } }, function()
            buneco1.tomou_dano = true
            vida1.tomou_dano = true
        end},
        {{ { 'Collisions', 'endContact', peteca.fixture, buneco1.main_fixture } }, function()
            buneco1.tomou_dano = false
            vida1.tomou_dano = false
        end},
        {{ 'vida1.acabou', '!vida2.acabou' }, function()
            esperando = true
            placar.ganhador = 1
            placar.hidden = false
        end},
        {{ '!vida1.acabou', 'vida2.acabou' }, function()
            esperando = true
            placar.ganhador = 2
            placar.hidden = false
        end},

        {{ { 'Collisions', 'postSolve', peteca.fixture, buneco2.raquete_fixture } }, function()
            local collinfo = nested.get(Collisions, 'postSolve', peteca.fixture, buneco2.raquete_fixture)
            peteca.impulso(collinfo)
        end},
        {{ { 'Collisions', 'touching', peteca.fixture, buneco2.main_fixture } }, function()
            buneco2.tomou_dano = true
            vida2.tomou_dano = true
        end},
        {{ { 'Collisions', 'endContact', peteca.fixture, buneco2.main_fixture } }, function()
            buneco2.tomou_dano = false
            vida2.tomou_dano = false
        end},
    }
end

function draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background)
end

function reset()
    reset_peteca()
    reset_buneco(buneco1, buneco1_x)
    reset_buneco(buneco2, buneco2_x)
    world:update(1 / 60) -- roda possíveis contatos antes de resetar a vida
    vida1.reset()
    vida2.reset()
end
function reset_peteca()
    peteca.body:setPosition(peteca_init_x, peteca_init_y)
    peteca.body:setAngle(0)
    peteca.body:setAngularVelocity(0)
    peteca.body:setLinearVelocity(0, 0.1)
end
function reset_buneco(buneco, x)
    buneco.body:setPosition(x, buneco_y)
    buneco.body:setLinearVelocity(0, 0.1)
    buneco.body:setAngle(0)
    buneco.body:setAngularVelocity(0)
end

when = {
    {{ '!esperando' }, function()
        world:update(dt)
    end},
    {{ 'esperando', 'Input.keypressed.return' }, function()
        esperando = false
        placar.hidden = true
        reset()
    end},

    {{ 'Input.keypressed.r' }, function()
        reset()
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
}