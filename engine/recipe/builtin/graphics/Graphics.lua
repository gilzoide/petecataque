local Graphics = {'Graphics'}

setmetatable(Graphics, { __index = love.graphics })

Graphics.draw_push = 'all'

return Graphics