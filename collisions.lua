local Collisions = {}
Collisions.__index = Collisions

function Collisions.new()
    return setmetatable({
        touching = {}
    }, Collisions)
end

function Collisions:onBeginContact(a, b, coll)
    local nx, ny = coll:getNormal()
    local info = { a = a, b = b, nx = nx, ny = ny }
    nested.set_or_create(self, {'beginContact', a, b}, info)
    nested.set_or_create(self, {'beginContact', b, a}, info)
    nested.set_or_create(self.touching, {a, b}, true)
    nested.set_or_create(self.touching, {b, a}, true)
end
function Collisions:onEndContact(a, b, coll)
    local nx, ny = coll:getNormal()
    local info = { a = a, b = b, nx = nx, ny = ny }
    nested.set_or_create(self, {'endContact', a, b}, info)
    nested.set_or_create(self, {'endContact', b, a}, info)
    nested.set(self.touching, {a, b}, nil)
    nested.set(self.touching, {b, a}, nil)
end
function Collisions:onPreSolve(a, b, coll)
    -- emit { 'preSolve', b, coll, target = a }
    -- emit { 'preSolve', a, coll, target = b }
end
function Collisions:onPostSolve(a, b, coll, normalimpulse, tangentimpulse)
    local nx, ny = coll:getNormal()
    local info = { a = a, b = b, nx = nx, ny = ny, normalimpulse = normalimpulse, tangentimpulse = tangentimpulse }
    nested.set_or_create(self, {'postSolve', a, b}, info)
    nested.set_or_create(self, {'postSolve', b, a}, info)
end

function Collisions:reset()
    self.beginContact = {}
    self.endContact = {}
    self.preSolve = {}
    self.postSolve = {}
end

return Collisions