local Frame = Recipe.new('Frame')

Frame.marginTop = 0
Frame.marginLeft = 0
Frame.marginBottom = 0
Frame.marginRight = 0

Frame.anchorTop = 0
Frame.anchorLeft = 0
Frame.anchorBottom = 1
Frame.anchorRight = 1

function Frame:calculate_layout()
    local parent_frame = self.__parent_frame
    if parent_frame.dirty then
        parent_frame:calculate_layout()
    end
    local parent_width, parent_height = parent_frame.width, parent_frame.height
    self._top = parent_height * self.anchorTop + self.marginTop
    self._left = parent_width * self.anchorLeft + self.marginLeft
    self._bottom = parent_height * self.anchorBottom + self.marginBottom
    self._right = parent_width * self.anchorRight + self.marginRight
    self._x = self._left
    self._y = self._top
    self._width = self._right - self._left
    self._height = self._bottom - self._top
    self.dirty = false
end

Frame.dirty = true

local root_frame = {
    x = 0, width = WINDOW_WIDTH,
    y = 0, height = WINDOW_HEIGHT,
}

function Frame:preinit()
    self.__parent_frame = self:first_parent_of('Frame') or root_frame
end
function Frame:init()
    self:calculate_layout()
end

function Frame:set_dirty(value)
    if not self.dirty then
        self.dirty = true
        self:invoke_next_frame('calculate_layout')
        self:invoke_next_frame('ondirty')
    end
end
Frame:add_setter('marginTop', Frame.set_dirty)
Frame:add_setter('marginLeft', Frame.set_dirty)
Frame:add_setter('marginBottom', Frame.set_dirty)
Frame:add_setter('marginRight', Frame.set_dirty)
Frame:add_setter('anchorTop', Frame.set_dirty)
Frame:add_setter('anchorLeft', Frame.set_dirty)
Frame:add_setter('anchorBottom', Frame.set_dirty)
Frame:add_setter('anchorRight', Frame.set_dirty)

Frame:add_getter('rect', function(self)
    return { self.top, self.left, self.bottom, self.right }
end)

Frame:add_setter('width', function(self, value)
    self.marginRight = self.marginLeft + value
    return Object.NO_RAWSET
end)
Frame:add_setter('height', function(self, value)
    self.marginBottom = self.marginTop + value
    return Object.NO_RAWSET
end)

Frame:add_getter('anchor', function(self)
    return { self.anchorTop, self.anchorLeft, self.anchorBottom, self.anchorRight }
end)
Frame:add_setter('anchor', function(self, value)
    self.anchorTop = value.top or value[1] or 0
    self.anchorLeft = value.left or value[2] or 0
    self.anchorBottom = value.bottom or value[3] or 1
    self.anchorRight = value.right or value[4] or 1
    return Object.NO_RAWSET
end)
Frame:add_getter('anchorX', function(self)
    return { self.anchorLeft, self.anchorRight }
end)
Frame:add_setter('anchorX', function(self, value)
    self.anchorLeft = value.left or value[1] or 0
    self.anchorRight = value.right or value[2] or 1
    return Object.NO_RAWSET
end)
Frame:add_getter('anchorY', function(self)
    return { self.anchorTop, self.anchorBottom }
end)
Frame:add_setter('anchorY', function(self, value)
    self.anchorTop = value.top or value[1] or 0
    self.anchorBottom = value.bottom or value[2] or 1
    return Object.NO_RAWSET
end)

Frame:add_getter('margin', function(self)
    return { self.marginTop, self.marginLeft, self.marginBottom, self.marginRight }
end)
Frame:add_setter('margin', function(self, value)
    self.marginTop = value.top or value[1] or 0
    self.marginLeft = value.left or value[2] or 0
    self.marginBottom = value.bottom or value[3] or 0
    self.marginRight = value.right or value[4] or 0
    return Object.NO_RAWSET
end)
Frame:add_getter('marginX', function(self)
    return { self.marginLeft, self.marginRight }
end)
Frame:add_setter('marginX', function(self, value)
    self.marginLeft = value.left or value[1] or 0
    self.marginRight = value.right or value[2] or 0
    return Object.NO_RAWSET
end)
Frame:add_getter('marginY', function(self)
    return { self.marginTop, self.marginBottom }
end)
Frame:add_setter('marginY', function(self, value)
    self.marginTop = value.top or value[1] or 0
    self.marginBottom = value.bottom or value[2] or 0
    return Object.NO_RAWSET
end)

Frame.draw_push = 'transform'
function Frame:draw()
    love.graphics.translate(self.left, self.top)
end

function Frame:hitTestFromOrigin(x, y)
    return x >= 0 and x <= self.width
        and y >= 0 and y <= self.height
end

return Frame
