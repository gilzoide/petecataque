self[1] = Rectangle{ x = 60, y = 60 }
self[2] = Rectangle{ x = 100, y = 200 }

function draw()
    love.graphics.clear({0.5, 0.5, 0.5})
end

on('mousepressed', { button = 1, presses = 1 }, function(x, y)
    local circle = Circle{ x = x, y = y }
    State:add_toplevel(circle)
end)