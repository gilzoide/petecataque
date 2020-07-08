local Text = {
    'Text',
    x = 0, y = 0,
    align = 'left',
}

function Text:draw()
    local text = self.text
    if type(text) == 'table' then text = string.format(unpack(text)) end
    if self.limit then
        love.graphics.printf(self.text, self.x, self.y, self.limit, self.align, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    else
        love.graphics.print(self.text, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    end
end

return Text