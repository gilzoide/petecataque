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

World.gravity = {0, 0}

function World:create_wrapped()
    local world = love.physics.newWorld()
    world:setCallbacks(
        bind(Collisions.onBeginContact, Collisions),
        bind(Collisions.onEndContact, Collisions),
        bind(Collisions.onPreSolve, Collisions),
        bind(Collisions.onPostSolve, Collisions)
    )
    return world
end

World["$xg"] = function(self)
    return self.gravity[1]
end
World["$yg"] = function(self)
    return self.gravity[2]
end
World["$set xg"] = function(self, xg)
    local gravity = self.gravity
    self.gravity = { xg, gravity[2] }
end
World["$set yg"] = function(self, yg)
    local gravity = self.gravity
    self.gravity = { gravity[1], yg }
end
World["$world"] = wrapper.get_wrapped

return World