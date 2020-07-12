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

function CircleShape:draw()
    if self.drawmode == 'fill' or self.drawmode == 'line' then
        local x, y = unpack(self.point)
        love.graphics.circle(self.drawmode, x, y, self.radius, self.segments)
    end
end

CircleShape["$shape"] = Recipe.wrapper.get_wrapped

return CircleShape