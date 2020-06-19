WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

function love.conf(t)
    t.window.width = WINDOW_WIDTH
    t.window.height = WINDOW_HEIGHT
    t.window.highdpi = true
    
    package.path = 'lib/?.lua;lib/?/init.lua;' .. (package.path or ';;')
end