local drawable_common = require 'wrapper.drawable.drawable_common'
local wrapper = require 'wrapper'
local Object = require 'Object'

local Text = wrapper.new('Text', {
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
Text["$set anchorPoint"] = drawable_common.setAnchorPoint

Text["$set text"] = function(self, text)
    local have_text = text and #text > 0
    self:enable_method('draw', have_text)
    if self.__wrapped then
        if self.limit then
            self.__wrapped:setf(text, self.limit, self.align)
        else
            self.__wrapped:set(text)
        end
    end
end

Text["$set width"] = function(self, width)
    self.limit = width
    return Object.SET_METHOD_NO_RAWSET
end

Text["$drawable"] = wrapper.get_wrapped

return Text