local Circle = {
    'Circle',
    x = 0, y = 0,
    radius = 10,
}

function Circle:__index(index)
    return self_or_first(self, index, rawget(self, 'shape'), Circle)
end

function Circle:init()
    self.shape = love.physics.newCircleShape(self.x, self.y, self.radius)
    self.hidden = self.mode ~= 'fill' and self.mode ~= 'line'
end

function Circle:draw()
    love.graphics.circle(self.mode, self.x, self.y, self.radius, self.segments)
end

return Circle