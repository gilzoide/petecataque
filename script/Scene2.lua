-- local child1 = addchild(Rectangle{ x = 60, y = 60 })
-- addchild(Rectangle{ x = 100, y = 200 })

background = background or Resources:get('image', 'image/fundo.png')

function draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background)
end

on('mousepressed', { button = 1, presses = 1 }, function(x, y)
    local circle = Circle{ x = x, y = y, color = {1, 1, 0} }
    addtoscene(circle)
end)