local Background = {'Background'}

function Background:__newindex(index, value)
    rawset(self, index, value)
    if index == 'color' then
        self:refresh()
    end
end

function Background:init()
    self:refresh()
end

function Background:refresh()
    if self.color then
        love.graphics.setBackgroundColor(self.color)
    end
end

return Background