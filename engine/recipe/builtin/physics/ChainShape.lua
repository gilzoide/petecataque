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

local default_points = { 0,0, 0,1 }
ChainShape.loop = true

function ChainShape:create_wrapped()
    return love.physics.newChainShape(self.loop, self.points or default_points)
end

function ChainShape:draw()
    if ColorStack:push(self.lineColor) then
        love.graphics.line(self.points)
        ColorStack:pop()
    end
end

return ChainShape
