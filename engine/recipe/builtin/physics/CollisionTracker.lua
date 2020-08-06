local CollisionTracker = Recipe.new('CollisionTracker')

CollisionTracker.touching = false

function CollisionTracker:init()
    local world = self.world
    if get(world, 'type') ~= 'World' then
        world = self:first_parent_of('World')
        self.world = world
    end
    if world and self.a and self.b then
        world:add_beginContact_handler(self, CollisionTracker.callBeginContact)
        world:add_endContact_handler(self, CollisionTracker.callEndContact)
        if self.preSolve then
            world:add_preSolve_handler(self, CollisionTracker.callPreSolve)
        end
        if self.postSolve then
            world:add_postSolve_handler(self, CollisionTracker.callPostSolve)
        end
    else
        DEBUG.WARNIF(not world, "Unable to create a CollisionTracker without a World")
        DEBUG.WARNIF(not self.a, "Unable to create a CollisionTracker without target 'a'")
        DEBUG.WARNIF(not self.b, "Unable to create a CollisionTracker without target 'b'")
        self.paused = true
    end
end

function CollisionTracker:callBeginContact(...)
    self.touching = true
    self:invoke('beginContact', ...)
end

function CollisionTracker:callEndContact(...)
    self.touching = false
    self:invoke('endContact', ...)
end

function CollisionTracker:callPreSolve(...)
    self:invoke('preSolve', ...)
end

function CollisionTracker:callPostSolve(...)
    self:invoke('postSolve', ...)
end

function CollisionTracker:match(a, b)
    return nested_match(a, self.a) and nested_match(b, self.b)
end

local argument_names = { 'a', 'b', 'contact', 'normal_impulse', 'tangent_impulse' }
local function bind_callback_argument_names(self, callback)
    Expression.bind_argument_names(callback, argument_names)
end

Object.add_setter(CollisionTracker, "beginContact", bind_callback_argument_names)
Object.add_setter(CollisionTracker, "endContact", bind_callback_argument_names)
Object.add_setter(CollisionTracker, "preSolve", bind_callback_argument_names)
Object.add_setter(CollisionTracker, "postSolve", bind_callback_argument_names)

return CollisionTracker
