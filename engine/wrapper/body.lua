local Body = {'Body'}

function Body:__index(index)
    return index_first_of(index, rawget(self, 'body'), Body)
end

function Body:init()
    self.body = love.physics.newBody(self.world, self.x, self.y, self.type)
end

function Body:release()
    self.body:destroy()
    self.body = nil
end

return Body