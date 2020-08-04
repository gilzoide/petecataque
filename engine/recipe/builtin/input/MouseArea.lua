local MouseArea = Recipe.new('MouseArea')
    
MouseArea.button = 1

function MouseArea:init()
    self.target = self:first_parent_with('hitTestFromOrigin')
    if not self.target then
        DEBUG.WARN("Couldn't find hitTestFromOrigin in MouseArea parent")
        self.paused = true
    end
end

function MouseArea:update(dt)
    local inside = self.__inside
    if inside and get(mouse, self.button, 'pressed') then
        self.down = true
        self.pressed = true
        set_next_frame(self, 'pressed', nil)
    end
    if self.down and get(mouse, self.button, 'released') then
        self.down = nil
        self.released = inside and 'inside' or 'outside' 
        set_next_frame(self, 'released', nil)
    end
    self.hover = inside
end

function MouseArea:draw()
    local x, y = love.graphics.inverseTransformPoint(unpack(mouse.position))
    self.__inside = self.target:hitTestFromOrigin(x, y)
end

return MouseArea
