local Frame = Recipe.new('Frame')

Frame.x = 0
Frame.y = 0
Frame.width = 100
Frame.height = 100

local root_frame = {
    x = 0, width = WINDOW_WIDTH,
    y = 0, height = WINDOW_HEIGHT,
}

function Frame:preinit()
    self.parent_frame = self:first_parent_of('Frame') or root_frame
end

Object.add_getter(Frame, 'left', function(self)
    return self.x
end)
Object.add_setter(Frame, 'left', function(self, value)
    self.x = value
end)
Object.add_getter(Frame, 'right', function(self)
    return self.parent_frame.width - (self.x + self.width)
end)
Object.add_setter(Frame, 'right', function(self, value)
    self.width = self.parent_frame.width - value - self.x
end)
Object.add_getter(Frame, 'top', function(self)
    return self.y
end)
Object.add_setter(Frame, 'top', function(self, value)
    self.y = value
end)
Object.add_getter(Frame, 'bottom', function(self)
    return self.parent_frame.height - (self.y + self.height)
end)
Object.add_setter(Frame, 'bottom', function(self, value)
    self.height = self.parent_frame.height - value - self.y
end)

Frame.draw_push = 'transform'
function Frame:draw()
    love.graphics.translate(self.x, self.y)
end

function Frame:hitTestFromOrigin(x, y)
    return x >= 0 and x <= self.width
        and y >= 0 and y <= self.height
end

return Frame
