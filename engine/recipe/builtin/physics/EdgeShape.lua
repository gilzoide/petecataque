local EdgeShape = Recipe.wrapper.new('EdgeShape', {
    extends = 'Shape.lua',
    getters = {
        'getNextVertex', 'getPoints', 'getPreviousVertex',
    },
    setters = {
        'setNextVertex', 'setPreviousVertex',
    },
})

local default_points = { 0,0, 0,1 }

function EdgeShape:create_wrapped()
    return love.physics.newEdgeShape(unpack(self.points or default_points))
end

function EdgeShape:draw()
    if ColorStack:push(self.lineColor) then
        love.graphics.line(self.points)
        ColorStack:pop()
    end
end

return EdgeShape
