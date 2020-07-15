local RectangleShape = Recipe.wrapper.new('RectangleShape', 'shape', {
    'getPoints',
    'getChildCount', 'getRadius', 'getType',
}, {

}, {
    'validate', 'computeAABB', 'computeMass', 'rayCast', 'testPoint',
})

RectangleShape.x = 0
RectangleShape.y = 0
RectangleShape.width = 1
RectangleShape.height = 1

function RectangleShape:create_wrapped()
    local shape = love.physics.newRectangleShape(self.x, self.y, self.width, self.height, self.angle)
    return shape
end

RectangleShape.draw_push = 'all'

function RectangleShape:draw()
    local fillColor = self.fillColor
    if fillColor then
        love.graphics.setColor(fillColor)
        love.graphics.polygon('fill', self.points)
    end
    local lineColor = self.lineColor
    if lineColor then
        love.graphics.setColor(lineColor)
        love.graphics.polygon('line', self.points)
    end
end

return RectangleShape