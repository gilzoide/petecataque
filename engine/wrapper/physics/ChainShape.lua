local ChainShape = Recipe.wrapper.new('ChainShape', 'shape', {
    'getChildEdge', 'getNextVertex', 'getPoints', 'getPreviousVertex', 'getVertexCount',
    'getChildCount', 'getRadius', 'getType',
}, {
    'setNextVertex', 'setPreviousVertex',
}, {
    'getPoint', 'computeAABB', 'computeMass', 'rayCast', 'testPoint',
})

ChainShape.points = { 0,0, 0,1 }
ChainShape.loop = true

function ChainShape:create_wrapped()
    local shape = love.physics.newChainShape(self.loop, self.points)
    return shape
end

ChainShape.draw_push = 'all'

function ChainShape:draw()
    local lineColor = self.lineColor
    if lineColor then
        love.graphics.setColor(lineColor)
        love.graphics.line(self.points)
    end
end

return ChainShape