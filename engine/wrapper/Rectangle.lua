local Rectangle = {
    'Rectangle',
    x = 0, y = 0,
    width = 100, height = 100,
    rx = nil, ry = nil, segments = nil,
    color = {1, 1, 1},
    mode = 'fill',
}

function Rectangle:draw()
    love.graphics.push('all')
    if self.mode == 'fill' or self.mode == 'line' then
        if self.rx then
            love.graphics.rectangle(self.mode, self.x, self.y, self.width, self.height, self.rx, self.ry, self.segments)
        else
            love.graphics.rectangle(self.mode, self.x, self.y, self.width, self.height)
        end
    end
    love.graphics.translate(self.x, self.y)
end

function Rectangle:draw_pop()
    love.graphics.pop()
end

function Rectangle:hitTestFromOrigin(x, y)
    return x >= 0 and x <= self.width
        and y >= 0 and y <= self.height
end

return Rectangle