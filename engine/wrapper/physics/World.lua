local World = Recipe.wrapper.new('World', 'world', {
    'getBodies', 'getBodyCount',
    'getContactCount', 'getContactFilter', 'getContacts',
    'getGravity', 'getJointCount', 'getJoints',
    'isDestroyed', 'isLocked', 'isSleepingAllowed',
}, {
    'setContactFilter', 'setGravity', 'setSleepingAllowed',
}, {
    'destroy', 'queryBoundingBox', 'rayCast', 'translateOrigin', 'update',
})

local function create_callback(handlers)
    return function(a, b, ...)
        a, b = a:getUserData(), b:getUserData()
        if not log.warnassert(a and b, "FIXME Fixture have no user data!!!") then return end
        for k, v in pairs(handlers) do
            if k:match(a, b) then
                v(k, a, b, ...)
            elseif k:match(b, a) then
                v(k, b, a, ...)
            end
        end
    end
end

World.gravity = {0, 0}

function World:create_wrapped()
    local world = love.physics.newWorld()
    self.beginContactHandlers = {}
    self.endContactHandlers = {}
    self.preSolveHandlers = {}
    self.postSolveHandlers = {}
    world:setCallbacks(
        create_callback(self.beginContactHandlers),
        create_callback(self.endContactHandlers),
        create_callback(self.preSolveHandlers),
        create_callback(self.postSolveHandlers)
    )
    return world
end

function World:add_beginContact_handler(handler, callback)
    self.beginContactHandlers[handler] = callback
end
function World:remove_beginContact_handler(handler)
    self.beginContactHandlers[handler] = nil
end

function World:add_endContact_handler(handler, callback)
    self.endContactHandlers[handler] = callback
end
function World:remove_endContact_handler(handler)
    self.endContactHandlers[handler] = nil
end

function World:add_preSolve_handler(handler, callback)
    self.preSolveHandlers[handler] = callback
end
function World:remove_preSolve_handler(handler)
    self.preSolveHandlers[handler] = nil
end

function World:add_postSolve_handler(handler, callback)
    self.postSolveHandlers[handler] = callback
end
function World:remove_postSolve_handler(handler)
    self.postSolveHandlers[handler] = nil
end

Object.add_getter(World, "xg", function(self)
    return self.gravity[1]
end)
Object.add_getter(World, "yg", function(self)
    return self.gravity[2]
end)

Object.add_setter(World, "xg", function(self)
    local gravity = self.gravity
    self.gravity = { xg, gravity[2] }
end)
Object.add_setter(World, "yg", function(self)
    local gravity = self.gravity
    self.gravity = { gravity[1], yg }
end)

return World