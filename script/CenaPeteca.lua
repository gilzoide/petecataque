color = {1, 1, 1}

gravidade = 9.81 * METER_BY_PIXEL
chao_e_paredes = {
    0, 0,
    WINDOW_WIDTH, 0,
    WINDOW_WIDTH, WINDOW_HEIGHT,
    0, WINDOW_HEIGHT
}
peteca_init_x = WINDOW_WIDTH * 0.5
peteca_init_y = 100


function init()
    background = R('image', 'image/fundo.png')
    world = R('world', 'world', 0, gravidade)
    body = love.physics.newBody(world)
    bounds_shape = love.physics.newChainShape(true, unpack(chao_e_paredes))
    fixture = love.physics.newFixture(body, bounds_shape)
    fixture:setFriction(0.9)
    
    peteca = Peteca { x = peteca_init_x, y = peteca_init_y }
    buneco = Buneco { x = WINDOW_WIDTH * 0.2, y = WINDOW_HEIGHT - Buneco.altura * 0.5 }
    addchild(peteca)
    addchild(buneco)
end

function draw()

end

function reset()

end

when = {
    {{ 'Input.keypressed.r' }, function()
        peteca.body:setPosition(peteca_init_x, peteca_init_y)
        peteca.body:setAngle(0)
        peteca.body:setAngularVelocity(0)
        peteca.body:setLinearVelocity(0, 0.1)
    end},
    {{ 'Input.keypressed.space' }, function()
        buneco.jump()
    end},
    {{ 'Input.keypressed.left' }, function()
        buneco.going_left = true
    end},
    {{ 'Input.keyreleased.left' }, function()
        buneco.going_left = false
    end},
    {{ 'Input.keypressed.right' }, function()
        buneco.going_right = true
    end},
    {{ 'Input.keyreleased.right' }, function()
        buneco.going_right = false
    end},
}