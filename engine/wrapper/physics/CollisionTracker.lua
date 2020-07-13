local empty = require 'empty'

local CollisionTracker = {'CollisionTracker'}

local argument_names = { 'self', 'fixture1', 'fixture2', 'contact', 'normal_impulse', 'tangent_impulse' }

function CollisionTracker:init()
    local world = self.world
    if get(world, 'type') ~= 'World' then
        world = self:first_parent_of('World')
        self.world = world
        log.warnassert(world, "Unable to create a CollisionTracker without a World")
    end
    if world and log.warnassert(self.a, self.b, "Unable to create a CollisionTracker without targets") then
        if self:expressionify('beginContact', argument_names) then
            world:add_beginContact_handler(self, self.beginContact)
        end
        if self:expressionify('endContact', argument_names) then
            world:add_endContact_handler(self, self.endContact)
        end
        if self:expressionify('preSolve', argument_names) then
            world:add_preSolve_handler(self, self.preSolve)
        end
        if self:expressionify('postSolve', argument_names) then
            world:add_postSolve_handler(self, self.postSolve)
        end
    else
        self.disabled = true
    end
end

function CollisionTracker:match(a, b)
    return a == self.a.fixture and b == self.b.fixture
end

return CollisionTracker