local Rectangle = Recipe.new('Rectangle')

Rectangle.x = 0
Rectangle.y = 0
Rectangle.width = 100
Rectangle.height = 100
Rectangle.anchorPoint = {0, 0}
-- rx = nil, ry = nil, segments = nil,

local function anchor_position(self)
    local x = self.width * self.anchorPoint[1]
    local y = self.height * self.anchorPoint[2]
    return x, y
end

Rectangle.draw_push = 'all'

local function draw_rectangle(self, drawmode, x, y)
    if self.rx then
        love.graphics.rectangle(drawmode, x, y, self.width, self.height, self.rx, self.ry, self.segments)
    else
        love.graphics.rectangle(drawmode, x, y, self.width, self.height)
    end
end

function Rectangle:draw()
    local ax, ay = anchor_position(self)
    local x, y = self.x - ax, self.y - ay
    
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

function Rectangle:hitTestFromOrigin(x, y)
    return x >= 0 and x <= self.width
        and y >= 0 and y <= self.height
end

return Rectangle