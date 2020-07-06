local Background = {'Background'}

function Background:draw()
    if self.color then
        love.graphics.clear(self.color)
    end
end

return Background