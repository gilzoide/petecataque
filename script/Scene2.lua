-- local child1 = addchild(Rectangle{ x = 60, y = 60 })
-- addchild(Rectangle{ x = 100, y = 200 })

function draw()
    love.graphics.clear({0.5, 0.5, 0.5})
end

on('mousepressed', { button = 1, presses = 1 }, function(x, y)
    local circle = Circle{ x = x, y = y, color = {1, 1, 0} }
    addtoscene(circle)
end)