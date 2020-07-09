local wrapper = require 'wrapper'

local EdgeShape = wrapper.new('EdgeShape', {
    'getNextVertex', 'getPoints', 'getPreviousVertex',
    'getChildCount', 'getRadius', 'getType',
}, {
    'setNextVertex', 'setPreviousVertex',
}, {
    'computeAABB', 'computeMass', 'rayCast', 'testPoint',
})

EdgeShape.points = { 0,0, 0,1 }

function EdgeShape:create_wrapped()
    local shape = love.physics.newEdgeShape(unpack(self.points))
    return shape
end

function EdgeShape:draw()
    if self.drawmode == 'line' then
        love.graphics.line(self.points)
    end
end

EdgeShape["$shape"] = wrapper.get_wrapped

return EdgeShape