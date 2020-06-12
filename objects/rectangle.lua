x, y = 10, 10
w, h = 100, 200
color = {1, 1, 0} -- yellow

function draw()
    love.graphics.setColor(color)
    love.graphics.rectangle('fill', x, y, w, h)
end

EventManager:register(self, 'draw')