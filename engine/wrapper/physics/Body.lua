local Body = Recipe.wrapper.new('Body', {
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

Body.draw_push = 'transform'

function Body:create_wrapped()
    local world = log.warnassert(self:first_parent_of('World'), "Couldn't find World in Body parent")
    if world then
        return love.physics.newBody(world.world)
    end
end

function Body:draw()
    love.graphics.replaceTransform(love.math.newTransform(self.x, self.y, self.angle))
end

Body["$body"] = Recipe.wrapper.get_wrapped

return Body