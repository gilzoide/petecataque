local CircleShape = Recipe.wrapper.new('CircleShape', nil, {
    'getPoint',
}, {
    'setPoint', 'setRadius',
}, nil)

Recipe.extends(CircleShape, 'Shape.lua')

CircleShape.radius = 10

function CircleShape:create_wrapped()
    return love.physics.newCircleShape(self.radius)
end

CircleShape.draw_push = 'all'

function CircleShape:draw()
    local x, y = unpack(self.point)
    local fillColor = self.fillColor
    if fillColor then
        love.graphics.setColor(fillColor)
        love.graphics.circle('fill', x, y, self.radius, self.segments)
    end
    local lineColor = self.lineColor
    if lineColor then
        love.graphics.setColor(lineColor)
        love.graphics.circle('line', x, y, self.radius, self.segments)
    end
end

return CircleShape