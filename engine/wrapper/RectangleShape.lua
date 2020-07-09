local wrapper = require 'wrapper'

local RectangleShape = wrapper.new('RectangleShape', {
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

function RectangleShape:draw()
    if self.drawmode == 'fill' or self.drawmode == 'line' then
        if self.rx then
            love.graphics.rectangle(self.drawmode, self.x, self.y, self.width, self.height, self.rx, self.ry, self.segments)
        else
            love.graphics.rectangle(self.drawmode, self.x, self.y, self.width, self.height)
        end
    end
end

RectangleShape["$shape"] = wrapper.get_wrapped

return RectangleShape