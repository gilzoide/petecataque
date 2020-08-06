local Text = Recipe.wrapper.new('Text', {
    extends = 'Frame',
    wrapped_index = 'drawable',
    getters = {
        'getDimensions', 'getFont', -- 'getHeight', 'getWidth',
    },
    setters = {
        'setFont'
    },
    method = {
        'add', 'addf', 'clear'
    },
})

local fallback_font = love.graphics.newFont()
Text.align = 'left'
Text.valign = 'top'

local function update_text(self, text)
    local width = self.width
    if width then
        self.drawable:setf(text, width, self.align)
    else
        self.drawable:set(text)
    end
end

function Text:create_wrapped()
    return love.graphics.newText(self.font or fallback_font, self.text)
end

function Text:update(dt)
    update_text(self, self.text)
end

Text.draw_push = 'transform'
function Text:draw()
    love.graphics.translate(self.left, self.top)

    local color = self.color
    if color then
        love.graphics.setColor(color)
    end

    local drawable = self.drawable
    local drawable_height = drawable:getHeight()
    if drawable_height > 0 then
        local vspace, valign, y = self.height - drawable_height, self.valign
        if valign == 'center' then
            y = vspace * 0.5
        elseif valign == 'bottom' then
            y = vspace
        else
            y = 0
        end
        love.graphics.draw(self.drawable, 0, y)
    end
end

Object.add_setter(Text, 'text', function(self, text)
    local is_getter = Expression.is_getter(text)
    self:set_method_enabled('update', is_getter)
    if not is_getter then
        update_text(self, text)
    end
end)

Object.add_getter(Text, 'width', function(self)
    return self.drawable:getWidth()
end)
Object.add_getter(Text, 'height', function(self)
    return self.drawable:getHeight()
end)

return Text
