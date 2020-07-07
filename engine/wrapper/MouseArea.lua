local MouseArea = {
    'MouseArea',
    button = 1,
}

function MouseArea:init()
    for p in self:iter_parents() do
        if p.hitTestFromOrigin then
            self.target = p
            break
        end
    end
    if not log.warnassert(self.target, "Couldn't find hitTestFromOrigin in MouseArea parent") then
        rawset(self, 'draw', false)
    end
end

function MouseArea:draw(dt)
    local x, y = love.graphics.inverseTransformPoint(unpack(mouse.position))
    local inside = self.target:hitTestFromOrigin(x, y)
    if inside and get(mouse, self.button, 'pressed') then
        self.pressed = true
        self.down = true
        set_next_frame(self, 'pressed', nil)
    end
    if self.down and get(mouse, self.button, 'released') then
        self.down = nil
        self.released = inside and 'inside' or 'outside' 
        set_next_frame(self, 'released', nil)
    end
    self.hover = inside
end

return MouseArea