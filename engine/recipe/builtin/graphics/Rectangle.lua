local Rectangle = Recipe.new('Rectangle', 'Frame.lua')

-- rx = nil, ry = nil, segments = nil,

local function draw_rectangle(self, drawmode, x, y)
    if self.rx then
        love.graphics.rectangle(drawmode, x, y, self.width, self.height, self.rx, self.ry, self.segments)
    else
        love.graphics.rectangle(drawmode, x, y, self.width, self.height)
    end
end

Rectangle.draw_push = 'all'
function Rectangle:draw()
    local x, y = self.left, self.top
    
    local fillColor = self.fillColor
    if fillColor then
        love.graphics.setColor(fillColor)
        draw_rectangle(self, 'fill', x, y)
    end
    local lineColor = self.lineColor
    if lineColor then
        love.graphics.setColor(lineColor)
        draw_rectangle(self, 'line', x, y)
    end

    love.graphics.translate(x, y)
end



return Rectangle
