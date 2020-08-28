local Body = Recipe.wrapper.new('Body', {
    wrapped_index = 'body',
    getters = {
        'getAngle', 'getAngularDamping', 'getAngularVelocity',
        'getContacts', 'getFixtures', 'getGravityScale',
        'getInertia', 'getJoints', 'getLinearDamping', 'getLinearVelocity',
        'getLocalCenter', 'getMass', 'getMassData',
        'getPosition', 'getType', 'getUserData', 'getWorld', 'getWorldCenter',
        'getX', 'getY', 'isActive', 'isAwake', 'isBullet', 'isDestroyed',
        'isFixedRotation', 'isSleepingAllowed',
    },
    setters = {
        'setActive', 'setAngle', 'setAngularDamping', 'setAngularVelocity',
        'setAwake', 'setBullet', 'setFixedRotation', 'setGravityScale',
        'setInertia', 'setLinearDamping', 'setLinearVelocity', 'setMass',
        'setMassData', 'setPosition', 'setSleepingAllowed', 'setType',
        'setUserData', 'setX', 'setY',
    },
    methods = {
        'applyAngularImpulse', 'applyForce', 'applyLinearImpulse', 'applyTorque', 'destroy',
        'getLinearVelocityFromLocalPoint', 'getLinearVelocityFromWorldPoint',
        'getLocalPoint', 'getLocalVector', 'getWorldPoint', 'getWorldPoints',
        'getWorldVector', 'isTouching', 'resetMassData',
    },
})

function Body:create_wrapped()
    local world = self.world
    if not world then
        world = self:first_parent_of('World')
        DEBUG.WARNIF(not world, "Couldn't find World in Body parent")
    end
    if world then
        return love.physics.newBody(world.world)
    else
        self.paused = true
    end
end

function Body:draw()
    love.graphics.push()
    love.graphics.origin()
    local x, y = self.body:getPosition()
    DEBUG.ONLY(function()
        x = x + DEBUG.x
        y = y + DEBUG.y
        love.graphics.scale(DEBUG.sx, DEBUG.sy)
    end)
    love.graphics.translate(x, y)
    love.graphics.rotate(self.angle)
end

Body.late_draw = love.graphics.pop

Body.__copy_state = {
    'active', 'position', 'angle', 'angularVelocity', 'linearVelocity'
}

return Body
