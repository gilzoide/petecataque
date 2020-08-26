local World = Recipe.wrapper.new('World', {
    wrapped_index = 'world',
    getters = {
        'getBodies', 'getBodyCount',
        'getContactCount', 'getContactFilter', 'getContacts',
        'getGravity', 'getJointCount', 'getJoints',
        'isDestroyed', 'isLocked', 'isSleepingAllowed',
    },
    setters = {
        'setContactFilter', 'setGravity', 'setSleepingAllowed',
    },
    methods = {
        'destroy', 'queryBoundingBox', 'rayCast', 'translateOrigin', 'update',
    }
})

local function create_callback(handlers)
    return function(a, b, ...)
        a, b = a:getUserData(), b:getUserData()
        if not (a and b) then
            DEBUG.WARN("FIXME Fixture have no user data!!!")
            return
        end
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

World:add_getter("xg", function(self)
    return self.gravity[1]
end)
World:add_getter("yg", function(self)
    return self.gravity[2]
end)

World:add_setter("xg", function(self, xg)
    local gravity = self.gravity
    self.gravity = { xg, gravity[2] }
end)
World:add_setter("yg", function(self, yg)
    local gravity = self.gravity
    self.gravity = { gravity[1], yg }
end)

return World
