local CircleShape = Recipe.wrapper.new('CircleShape', {
    'getPoint', 'getRadius', 'getChildCount', 'getType',
}, {
    'setPoint', 'setRadius',
}, {
    'computeAABB', 'computeMass', 'rayCast', 'testPoint',
})

CircleShape.radius = 10

function CircleShape:create_wrapped()
    local shape = love.physics.newCircleShape(self.radius)
    return shape
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

CircleShape["$shape"] = Recipe.wrapper.get_wrapped

return CircleShape