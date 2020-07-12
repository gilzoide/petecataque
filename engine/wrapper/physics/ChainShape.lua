local ChainShape = Recipe.wrapper.new('ChainShape', {
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

function ChainShape:draw()
    if self.drawmode == 'line' then
        love.graphics.line(self.points)
    end
end

ChainShape["$shape"] = Recipe.wrapper.get_wrapped

return ChainShape