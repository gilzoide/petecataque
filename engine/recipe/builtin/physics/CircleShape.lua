local CircleShape = Recipe.wrapper.new('CircleShape', {
    extends = 'Shape.lua',
    getters = {
        'getPoint',
    },
    setters = {
        'setPoint', 'setRadius',
    },
})

local default_radius = 10

function CircleShape:create_wrapped()
    return love.physics.newCircleShape(self.radius or default_radius)
end

function CircleShape:draw()
    local x, y = unpack(self.point)

    if ColorStack:push(self.fillColor) then
        love.graphics.circle('fill', x, y, self.radius, self.segments)
        ColorStack:pop()
    end
    if ColorStack:push(self.lineColor) then
        love.graphics.circle('line', x, y, self.radius, self.segments)
        ColorStack:pop()
    end
end

return CircleShape
