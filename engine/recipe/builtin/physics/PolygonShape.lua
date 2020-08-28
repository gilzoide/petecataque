local PolygonShape = Recipe.wrapper.new('PolygonShape', {
    extends = 'Shape.lua',
    getters = {
        'getPoints',
    },
    methods = {
        'validate',
    },
})

local default_points = { 0,0, 0,1, 1,1, 1,0 }

function PolygonShape:create_wrapped()
    return love.physics.newPolygonShape(self.points or default_points)
end

function PolygonShape:draw()
    if ColorStack:push(self.fillColor) then
        love.graphics.polygon('fill', self.points)
        ColorStack:pop()
    end
    if ColorStack:push(self.lineColor) then
        love.graphics.polygon('line', self.points)
        ColorStack:pop()
    end
end

return PolygonShape
