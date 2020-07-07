local Circle = {
    'Circle',
    x = 0, y = 0,
    radius = 10,
}

function Circle:init()
    self.shape = love.physics.newCircleShape(self.x, self.y, self.radius)
end

function Circle:draw()
    if self.mode == 'fill' or self.mode == 'line' then
        love.graphics.circle(self.mode, self.x, self.y, self.radius, self.segments)
    end
end

return Circle