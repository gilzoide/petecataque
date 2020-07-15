local Body = Recipe.wrapper.new('Body', 'body', {
    'getAngle', 'getAngularDamping', 'getAngularVelocity',
    'getContacts', 'getFixtures', 'getGravityScale',
    'getInertia', 'getJoints', 'getLinearDamping', 'getLinearVelocity',
    'getLocalCenter', 'getMass', 'getMassData',
    'getPosition', 'getType', 'getUserData', 'getWorld', 'getWorldCenter',
    'getX', 'getY', 'isActive', 'isAwake', 'isBullet', 'isDestroyed',
    'isFixedRotation', 'isSleepingAllowed',
}, {
    'setActive', 'setAngle', 'setAngularDamping', 'setAngularVelocity',
    'setAwake', 'setBullet', 'setFixedRotation', 'setGravityScale',
    'setInertia', 'setLinearDamping', 'setLinearVelocity', 'setMass',
    'setMassData', 'setPosition', 'setSleepingAllowed', 'setType',
    'setUserData', 'setX', 'setY',
}, {
    'applyAngularImpulse', 'applyForce', 'applyLinearImpulse', 'applyTorque', 'destroy',
    'getLinearVelocityFromLocalPoint', 'getLinearVelocityFromWorldPoint',
    'getLocalPoint', 'getLocalVector', 'getWorldPoint', 'getWorldPoints',
    'getWorldVector', 'isTouching', 'resetMassData',
})

function Body:create_wrapped()
    local world = self.world
    if not world then
        world = select(2, self:first_parent_with('world'))
        log.warnassert(world, "Couldn't find World in Body parent")
    end
    if world then
        return love.physics.newBody(world)
    else
        self.disabled = true
    end
end

Body.draw_push = 'transform'

function Body:draw()
    love.graphics.replaceTransform(love.math.newTransform(self.x, self.y, self.angle))
end

return Body