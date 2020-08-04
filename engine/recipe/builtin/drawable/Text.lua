local drawable_common = require 'recipe.builtin.drawable._common'

local Text = Recipe.wrapper.new('Text', {
    wrapped_index = 'drawable',
    getters = {
        'getDimensions', 'getFont', 'getHeight', 'getWidth',
    },
    setters = {
        'setFont'
    },
    method = {
        'add', 'addf', 'clear'
    },
})

Text.font = love.graphics.getFont()

function Text:create_wrapped()
    return love.graphics.newText(self.font, self.text)
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

Object.add_getter(Text, "left", function(self)
    return self.x
end)
Object.add_getter(Text, "right", function(self)
    return self.x + self.width
end)
Object.add_getter(Text, "top", function(self)
    return self.y
end)
Object.add_getter(Text, "bottom", function(self)
    return self.y + self.height
end)

return Text
