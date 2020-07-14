local empty = require 'empty'

local CollisionTracker = {
    'CollisionTracker',
    touching = false,
}

local argument_names = { 'self', 'a', 'b', 'contact', 'normal_impulse', 'tangent_impulse' }

function CollisionTracker:init()
    local world = self.world
    if get(world, 'type') ~= 'World' then
        world = self:first_parent_of('World')
        self.world = world
        log.warnassert(world, "Unable to create a CollisionTracker without a World")
    end
    if world and log.warnassert(self.a, self.b, "Unable to create a CollisionTracker without targets") then
        self:expressionify('beginContact', argument_names)
        world:add_beginContact_handler(self, CollisionTracker.callBeginContact)
        self:expressionify('endContact', argument_names)
        world:add_endContact_handler(self, CollisionTracker.callEndContact)
        if self:expressionify('preSolve', argument_names) then
            world:add_preSolve_handler(self, CollisionTracker.callPreSolve)
        end
        if self:expressionify('postSolve', argument_names) then
            world:add_postSolve_handler(self, CollisionTracker.callPostSolve)
        end
    else
        self.disabled = true
    end
end

function CollisionTracker:callBeginContact(...)
    DEBUG.PUSH_CALL(self[1], 'beginContact', self.__line)
    self.touching = true
    local callback = self.beginContact
    if callback then callback(self, ...) end
    DEBUG.POP_CALL(self[1], 'beginContact')
end

function CollisionTracker:callEndContact(...)
    DEBUG.PUSH_CALL(self[1], 'endContact', self.__line)
    self.touching = false
    local callback = self.endContact
    if callback then callback(self, ...) end
    DEBUG.POP_CALL(self[1], 'endContact')
end

function CollisionTracker:callPreSolve(...)
    DEBUG.PUSH_CALL(self[1], 'preSolve', self.__line)
    self:preSolve(...)
    DEBUG.POP_CALL(self[1], 'preSolve')
end

function CollisionTracker:callPostSolve(...)
    DEBUG.PUSH_CALL(self[1], 'postSolve', self.__line)
    self:postSolve(...)
    DEBUG.POP_CALL(self[1], 'postSolve')
end

function CollisionTracker:match(a, b)
    return nested_match(a, self.a) and nested_match(b, self.b)
end

return CollisionTracker