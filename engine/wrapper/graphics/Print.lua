local drawable_common = require 'wrapper.drawable.drawable_common'

local Print = {
    'Print',
    x = 0, y = 0,
}

local function disable_draw_if_empty_text(self, text)
    local have_text = text and #text > 0
    self:enable_method('draw', have_text)
end

function Print:init()
    disable_draw_if_empty_text(self, self.text)
end

function Print:draw()
    if self.limit then
        love.graphics.printf(self.text, self.x, self.y, self.limit, self.align, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    else
        love.graphics.print(self.text, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    end
end

Print["$set text"] = disable_draw_if_empty_text

return Print