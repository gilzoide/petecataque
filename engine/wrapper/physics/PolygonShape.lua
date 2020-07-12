local PolygonShape = Recipe.wrapper.new('PolygonShape', {
    'getPoints',
    'getChildCount', 'getRadius', 'getType',
}, {

}, {
    'validate', 'computeAABB', 'computeMass', 'rayCast', 'testPoint',
})

PolygonShape.points = { 0,0, 0,1, 1,1, 1,0 }

function PolygonShape:create_wrapped()
    local shape = love.physics.newPolygonShape(self.points)
    return shape
end

function PolygonShape:draw()
    if self.drawmode == 'fill' or self.drawmode == 'line' then
        love.graphics.polygon(self.drawmode, self.points)
    end
end

PolygonShape["$shape"] = Recipe.wrapper.get_wrapped

return PolygonShape