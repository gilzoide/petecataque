self[1] = Rectangle{ x = 60, y = 60 }
self[2] = Rectangle{ x = 100, y = 200 }

function draw()
    love.graphics.clear({0.5, 0.5, 0.5})
end

on('mousepressed', '1', function(istouch, presses, x, y)
    if presses > 1 then return end
    local circle = Circle{ x = x, y = y }
    State:add_toplevel(circle)
end)