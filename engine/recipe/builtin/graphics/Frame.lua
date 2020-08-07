local Frame = Recipe.new('Frame')

Frame.marginTop = 0
Frame.marginLeft = 0
Frame.marginBottom = 0
Frame.marginRight = 0

Frame.anchorTop = 0
Frame.anchorLeft = 0
Frame.anchorBottom = 1
Frame.anchorRight = 1

Frame.dirty = false

local root_frame = {
    x = 0, width = WINDOW_WIDTH,
    y = 0, height = WINDOW_HEIGHT,
}

function Frame:preinit()
    self.__parent_frame = self:first_parent_of('Frame') or root_frame
end

local function set_dirty(self, value)
    if not self.dirty then
        self.dirty = true
        self:invoke_next_frame('ondirty')
        set_next_frame(self, 'dirty', false)
    end
end
Object.add_setter(Frame, 'marginTop', set_dirty)
Object.add_setter(Frame, 'marginLeft', set_dirty)
Object.add_setter(Frame, 'marginBottom', set_dirty)
Object.add_setter(Frame, 'marginRight', set_dirty)
Object.add_setter(Frame, 'anchorTop', set_dirty)
Object.add_setter(Frame, 'anchorLeft', set_dirty)
Object.add_setter(Frame, 'anchorBottom', set_dirty)
Object.add_setter(Frame, 'anchorRight', set_dirty)

Object.add_getter(Frame, 'left', function(self)
    return self.__parent_frame.width * self.anchorLeft + self.marginLeft
end)
Object.add_getter(Frame, 'top', function(self)
    return self.__parent_frame.height * self.anchorTop + self.marginTop
end)
Object.add_getter(Frame, 'right', function(self)
    return self.__parent_frame.width * self.anchorRight + self.marginRight
end)
Object.add_getter(Frame, 'bottom', function(self)
    return self.__parent_frame.height * self.anchorBottom + self.marginBottom
end)
Object.add_getter(Frame, 'rect', function(self)
    return { self.top, self.left, self.bottom, self.right }
end)

Object.add_getter(Frame, 'x', function(self)
    return self.left
end)
Object.add_getter(Frame, 'y', function(self)
    return self.top
end)
Object.add_getter(Frame, 'width', function(self)
    return self.right - self.left
end)
Object.add_setter(Frame, 'width', function(self, value)
    DEBUG.WARNIF(self.anchorLeft ~= self.anchorRight, "Setting width only makes sense when anchors X values are the same, got %s and %s",
            self.anchorLeft, self.anchorRight)
    self.marginRight = self.marginLeft + value
    return Object.NO_RAWSET
end)
Object.add_getter(Frame, 'height', function(self)
    return self.bottom - self.top
end)
Object.add_setter(Frame, 'height', function(self, value)
    DEBUG.WARNIF(self.anchorTop ~= self.anchorBottom, "Setting height only makes sense when anchors Y values are the same, got %f and %f",
            self.anchorTop, self.anchorBottom)
    self.marginBottom = self.marginTop + value
    return Object.NO_RAWSET
end)

Object.add_getter(Frame, 'anchor', function(self)
    return { self.anchorTop, self.anchorLeft, self.anchorBottom, self.anchorRight }
end)
Object.add_setter(Frame, 'anchor', function(self, value)
    self.anchorTop = value.top or value[1] or 0
    self.anchorLeft = value.left or value[2] or 0
    self.anchorBottom = value.bottom or value[3] or 1
    self.anchorRight = value.right or value[4] or 1
    return Object.NO_RAWSET
end)
Object.add_getter(Frame, 'anchorX', function(self)
    return { self.anchorLeft, self.anchorRight }
end)
Object.add_setter(Frame, 'anchorX', function(self, value)
    self.anchorLeft = value.left or value[1] or 0
    self.anchorRight = value.right or value[2] or 1
    return Object.NO_RAWSET
end)
Object.add_getter(Frame, 'anchorY', function(self)
    return { self.anchorTop, self.anchorBottom }
end)
Object.add_setter(Frame, 'anchorY', function(self, value)
    self.anchorTop = value.top or value[1] or 0
    self.anchorBottom = value.bottom or value[2] or 1
    return Object.NO_RAWSET
end)

Object.add_getter(Frame, 'margin', function(self)
    return { self.marginTop, self.marginLeft, self.marginBottom, self.marginRight }
end)
Object.add_setter(Frame, 'margin', function(self, value)
    self.marginTop = value.top or value[1] or 0
    self.marginLeft = value.left or value[2] or 0
    self.marginBottom = value.bottom or value[3] or 0
    self.marginRight = value.right or value[4] or 0
    return Object.NO_RAWSET
end)
Object.add_getter(Frame, 'marginX', function(self)
    return { self.marginLeft, self.marginRight }
end)
Object.add_setter(Frame, 'marginX', function(self, value)
    self.marginLeft = value.left or value[1] or 0
    self.marginRight = value.right or value[2] or 0
    return Object.NO_RAWSET
end)
Object.add_getter(Frame, 'marginY', function(self)
    return { self.marginTop, self.marginBottom }
end)
Object.add_setter(Frame, 'marginY', function(self, value)
    self.marginTop = value.top or value[1] or 0
    self.marginBottom = value.bottom or value[2] or 0
    return Object.NO_RAWSET
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
