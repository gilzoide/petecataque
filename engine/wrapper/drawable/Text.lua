local drawable_common = require 'wrapper.drawable.drawable_common'

local Text = Recipe.wrapper.new('Text', 'drawable', {
    'getDimensions', 'getFont', 'getHeight', 'getWidth',
}, {
    'setFont'
}, {
    'add', 'addf', 'clear'
})

Text.font = love.graphics.getFont()

function Text:create_wrapped()
    local obj = love.graphics.newText(self.font, self.text)
    return obj
end

Text.draw_push = 'transform'
Text.draw = drawable_common.draw
Text.hitTestFromOrigin = drawable_common.hitTestFromOrigin
Object.add_setter(Text, 'anchorPoint', drawable_common.setAnchorPoint)

Object.add_setter(Text, 'text', function(self, text)
    local have_text = text and #text > 0
    self:enable_method('draw', have_text)
    if self.drawable then
        if self.limit then
            self.drawable:setf(text, self.limit, self.align)
        else
            self.drawable:set(text)
        end
    end
end)

Object.add_setter(Text, 'width', function(self, width)
    self.limit = width
    return Object.SET_METHOD_NO_RAWSET
end)

return Text