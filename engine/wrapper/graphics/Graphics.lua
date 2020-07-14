local Graphics = {'Graphics'}

setmetatable(Graphics, { __index = love.graphics })

Graphics.draw_push = 'all'

Graphics["$set push"] = function(self, push)
    self.draw_push = push
end

return Graphics