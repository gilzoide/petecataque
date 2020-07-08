local Font = {
    'Font',
    loaded_font = love.graphics.getFont(),
}

function Font:init()
    local font = self.load
    self.loaded_font = font and log.warnassert(R.font[font])
end

function Font:draw()
    love.graphics.setFont(self.loaded_font)
end

return Font