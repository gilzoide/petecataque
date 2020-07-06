local Body = {'Body'}

function Body:__index(index)
    return self_or_first(self, index, rawget(self, 'body'), Body)
end

function Body:init()
    self.body = love.physics.newBody(self.world, self.x, self.y, self.type)
end

function Body:release()
    self.body:destroy()
    self.body = nil
end

return Body