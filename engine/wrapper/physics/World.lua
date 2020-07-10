local wrapper = require 'wrapper'

local World = wrapper.new('World', {
    'getBodies', 'getBodyCount',
    'getContactCount', 'getContactFilter', 'getContacts',
    'getGravity', 'getJointCount', 'getJoints',
    'isDestroyed', 'isLocked', 'isSleepingAllowed',
}, {
    'setContactFilter', 'setGravity', 'setSleepingAllowed',
}, {
    'destroy', 'queryBoundingBox', 'rayCast', 'translateOrigin', 'update',
})

function World:create_wrapped()
    local world = love.physics.newWorld(self.xg, self.yg, self.sleep)
    world:setCallbacks(
        bind(Collisions.onBeginContact, Collisions),
        bind(Collisions.onEndContact, Collisions),
        bind(Collisions.onPreSolve, Collisions),
        bind(Collisions.onPostSolve, Collisions)
    )
    return world
end

World["$world"] = wrapper.get_wrapped

return World