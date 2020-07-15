local empty = require 'empty'

local CollisionTracker = {
    'CollisionTracker',
    touching = false,
}

local argument_names = { 'a', 'b', 'contact', 'normal_impulse', 'tangent_impulse' }
local function bind_callback_argument_names(callback)
    Expression.bind_argument_names(callback, argument_names)
end

function CollisionTracker:init()
    local world = self.world
    if get(world, 'type') ~= 'World' then
        world = self:first_parent_of('World')
        self.world = world
        log.warnassert(world, "Unable to create a CollisionTracker without a World")
    end
    if world and log.warnassert(self.a, self.b, "Unable to create a CollisionTracker without targets") then
        bind_callback_argument_names(self.beginContact)
        world:add_beginContact_handler(self, CollisionTracker.callBeginContact)
        bind_callback_argument_names(self.endContact)
        world:add_endContact_handler(self, CollisionTracker.callEndContact)
        if self.preSolve then
            bind_callback_argument_names(self.preSolve)
            world:add_preSolve_handler(self, CollisionTracker.callPreSolve)
        end
        if self.postSolve then
            bind_callback_argument_names(self.postSolve)
            world:add_postSolve_handler(self, CollisionTracker.callPostSolve)
        end
    else
        self.disabled = true
    end
end

function CollisionTracker:callBeginContact(...)
    DEBUG.PUSH_CALL(self, 'beginContact')
    self.touching = true
    local callback = self.beginContact
    if callback then callback(self, ...) end
    DEBUG.POP_CALL(self, 'beginContact')
end

function CollisionTracker:callEndContact(...)
    DEBUG.PUSH_CALL(self, 'endContact')
    self.touching = false
    local callback = self.endContact
    if callback then callback(self, ...) end
    DEBUG.POP_CALL(self, 'endContact')
end

function CollisionTracker:callPreSolve(...)
    DEBUG.PUSH_CALL(self, 'preSolve')
    self:preSolve(...)
    DEBUG.POP_CALL(self, 'preSolve')
end

function CollisionTracker:callPostSolve(...)
    DEBUG.PUSH_CALL(self, 'postSolve')
    self:postSolve(...)
    DEBUG.POP_CALL(self, 'postSolve')
end

function CollisionTracker:match(a, b)
    return nested_match(a, self.a) and nested_match(b, self.b)
end

-- Object.add_setter(CollisionTracker, "beginContact", bind_callback_argument_names)
-- Object.add_setter(CollisionTracker, "endContact", bind_callback_argument_names)
-- Object.add_setter(CollisionTracker, "preSolve", bind_callback_argument_names)
-- Object.add_setter(CollisionTracker, "postSolve", bind_callback_argument_names)

return CollisionTracker