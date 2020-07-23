local RectangleShape = Recipe.wrapper.new('RectangleShape', {
    extends = 'PolygonShape.lua',
})

RectangleShape.x = 0
RectangleShape.y = 0
RectangleShape.width = 1
RectangleShape.height = 1

function RectangleShape:create_wrapped()
    return love.physics.newRectangleShape(self.x, self.y, self.width, self.height, self.angle)
end

return RectangleShape