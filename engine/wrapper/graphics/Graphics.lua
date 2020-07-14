local Graphics = {'Graphics'}

setmetatable(Graphics, { __index = love.graphics })

function Graphics:init()
    self:enable_method('draw', self['do'])
end

Graphics.draw_push = 'all'

function Graphics:draw()
    self['do']()
end

Graphics["$set do"] = function(self, _do)
    self:enable_method('draw', _do)
    if _do then
        return self:create_expression(_do)
    end
end

Graphics["$set push"] = function(self, push)
    self.draw_push = push
end

return Graphics