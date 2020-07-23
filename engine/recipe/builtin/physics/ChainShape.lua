local ChainShape = Recipe.wrapper.new('ChainShape', {
    extends = 'Shape.lua',
    getters = {
        'getChildEdge', 'getNextVertex', 'getPoints', 'getPreviousVertex', 'getVertexCount',
    },
    setters = {
        'setNextVertex', 'setPreviousVertex',
    },
    methods = {
        'getPoint'
    },
})

ChainShape.points = { 0,0, 0,1 }
ChainShape.loop = true

function ChainShape:create_wrapped()
    return love.physics.newChainShape(self.loop, self.points)
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