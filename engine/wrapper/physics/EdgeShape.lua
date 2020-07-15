local EdgeShape = Recipe.wrapper.new('EdgeShape', 'shape', {
    'getNextVertex', 'getPoints', 'getPreviousVertex',
    'getChildCount', 'getRadius', 'getType',
}, {
    'setNextVertex', 'setPreviousVertex',
}, {
    'computeAABB', 'computeMass', 'rayCast', 'testPoint',
})

EdgeShape.points = { 0,0, 0,1 }

function EdgeShape:typeOf(t)
    return t == 'Shape' or t == 'EdgeShape'
end

function EdgeShape:create_wrapped()
    local shape = love.physics.newEdgeShape(unpack(self.points))
    return shape
end

EdgeShape.draw_push = 'all'

function EdgeShape:draw()
    local lineColor = self.lineColor
    if lineColor then
        love.graphics.setColor(lineColor)
        love.graphics.line(self.points)
    end
end

return EdgeShape