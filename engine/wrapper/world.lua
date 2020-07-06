local World = {'World'}

function World:__index(index)
    return index_first_of(index, rawget(self, 'world'), World)
end

function World:init()
    self.world = love.physics.newWorld(self.xg, self.yg, self.sleep)
    self.world:setCallbacks(
        bind(Collisions.onBeginContact, Collisions),
        bind(Collisions.onEndContact, Collisions),
        bind(Collisions.onPreSolve, Collisions),
        bind(Collisions.onPostSolve, Collisions)
    )
end

function World:release()
    self.world:destroy()
    self.world = nil
end

return World