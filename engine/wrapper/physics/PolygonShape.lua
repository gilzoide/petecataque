local PolygonShape = Recipe.wrapper.new('PolygonShape', 'shape', {
    'getPoints',
    'getChildCount', 'getRadius', 'getType',
}, {

}, {
    'validate', 'computeAABB', 'computeMass', 'rayCast', 'testPoint',
})

PolygonShape.points = { 0,0, 0,1, 1,1, 1,0 }

function PolygonShape:typeOf(t)
    return t == 'Shape' or t == 'PolygonShape'
end

function PolygonShape:create_wrapped()
    local shape = love.physics.newPolygonShape(self.points)
    return shape
end

PolygonShape.draw_push = 'all'

function PolygonShape:draw()
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

return PolygonShape