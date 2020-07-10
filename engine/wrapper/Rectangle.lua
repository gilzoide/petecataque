local Rectangle = {
    'Rectangle',
    x = 0, y = 0,
    width = 100, height = 100,
    rx = nil, ry = nil, segments = nil,
    color = {1, 1, 1},
    anchorPoint = {0, 0},
    drawmode = 'fill',
}

local function anchor_position(self)
    local x = self.width * self.anchorPoint[1]
    local y = self.height * self.anchorPoint[2]
    return x, y
end

Rectangle.draw_push = 'transform'
function Rectangle:draw()
    local ax, ay = anchor_position(self)
    local x, y = self.x - ax, self.y - ay
    if self.drawmode == 'fill' or self.drawmode == 'line' then
        if self.rx then
            love.graphics.rectangle(self.drawmode, x, y, self.width, self.height, self.rx, self.ry, self.segments)
        else
            love.graphics.rectangle(self.drawmode, x, y, self.width, self.height)
        end
    end
    love.graphics.translate(x, y)
end

function Rectangle:hitTestFromOrigin(x, y)
    return x >= 0 and x <= self.width
        and y >= 0 and y <= self.height
end

Rectangle["$set anchorPoint"] = function(self, anchorPoint)
    anchorPoint[1] = clamp(anchorPoint[1], 0, 1)
    anchorPoint[2] = clamp(anchorPoint[2], 0, 1)
    return anchorPoint
end

return Rectangle