local EdgeShape = Recipe.wrapper.new('EdgeShape', {
    extends = 'Shape.lua',
    getters = {
        'getNextVertex', 'getPoints', 'getPreviousVertex',
    },
    setters = {
        'setNextVertex', 'setPreviousVertex',
    },
})

EdgeShape.points = { 0,0, 0,1 }

function EdgeShape:create_wrapped()
    return love.physics.newEdgeShape(unpack(self.points))
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