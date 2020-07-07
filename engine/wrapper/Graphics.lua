local Graphics = {
    'Graphics',
}

function Graphics:init()
    self:expressionify('do', love.graphics)
end

function Graphics:draw()
    if self.push then love.graphics.push(self.push) end
    if self['do'] then self['do']() end
end

function Graphics:draw_pop()
    if self.push then love.graphics.pop() end
end

return Graphics