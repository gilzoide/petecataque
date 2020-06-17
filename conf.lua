function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.highdpi = true
    
    package.path = 'lib/?.lua;lib/?/init.lua;' .. (package.path or ';;')
end