local Image = Recipe.wrapper.new('Image', 'image', {
    'getFlags', 'isCompressed',
}, 
nil
, {
    'replacePixels',
})

Recipe.extends(Image, 'Texture')

function Image:create_wrapped()
    local image = self.image
    if image then
        return image
    end
    
    local data = self.data
    if data then
        return love.graphics.newImage(data)
    end

    return love.graphics.newImage(self.filename, self.flags)
end

function Image:draw()
    local color, r, g, b, a = self.color
    if color then
        r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(color)
    end
    love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    if color then
        love.graphics.setColor(r, g, b, a)
    end
end

return Image