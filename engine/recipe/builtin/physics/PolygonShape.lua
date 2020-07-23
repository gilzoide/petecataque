local PolygonShape = Recipe.wrapper.new('PolygonShape', {
    extends = 'Shape.lua',
    getters = {
        'getPoints',
    },
    methods = {
        'validate',
    },
})

function PolygonShape:create_wrapped()
    return love.physics.newPolygonShape(self.points or { 0,0, 0,1, 1,1, 1,0 })
end

PolygonShape.draw_push = 'all'

function PolygonShape:draw()
    local fillColor = self.fillColor
    if fillColor then
        love.graphics.setColor(fillColor)
        love.graphics.polygon('fill', self.points)
    end
    local lineColor = self.lineColor
    if lineColor then
        love.graphics.setColor(lineColor)
        love.graphics.polygon('line', self.points)
    end
end

return PolygonShape