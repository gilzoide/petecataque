local child1 = Rectangle{ x = 60, y = 60 }
self[1] = child1
self[2] = Rectangle{ x = 100, y = 200 }

function draw()
    love.graphics.clear({0.5, 0.5, 0.5})
end

on('mousepressed', { button = 1, presses = 1 }, function(x, y)
    local circle = Circle{ x = x, y = y, color = {1, 1, 0} }
    State:add_toplevel(circle)
end)

on('mousemoved', function(x, y, dx, dy)
    child1.x, child1.y = x, y
    child1.refresh_transform()
end)