local Circle = {
    'Circle',
    drawmode = 'fill',
    x = 0, y = 0,
    radius = 10,
}

function Circle:draw()
    love.graphics.circle(self.drawmode, self.x, self.y, self.radius, self.segments)
end

return Circle