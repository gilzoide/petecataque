local Rectangle = Recipe.new('Rectangle', 'Frame')

-- rx = nil, ry = nil, segments = nil,

local function draw_rectangle(self, drawmode)
    if self.rx then
        love.graphics.rectangle(drawmode, 0, 0, self.width, self.height, self.rx, self.ry, self.segments)
    else
        love.graphics.rectangle(drawmode, 0, 0, self.width, self.height)
    end
end

function Rectangle:draw()
    Rectangle:invoke_super('draw', self)
    
    if ColorStack:push(self.fillColor) then
        draw_rectangle(self, 'fill')
        ColorStack:pop()
    end
    if ColorStack:push(self.lineColor) then
        draw_rectangle(self, 'line')
        ColorStack:pop()
    end
end

return Rectangle
