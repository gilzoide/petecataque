mode = mode or 'fill'
segments = segments
x = x or 0
y = y or 0
radius = radius or 10
color = color or {1, 1, 1}
body = body or nil

function draw()
    love.graphics.setColor(color)
    love.graphics.circle(mode, body and body:getX() or x, body and body:getY() or y, radius, segments)
end