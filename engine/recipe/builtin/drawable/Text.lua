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

function Text:__init_recipe(recipe)
    local text = recipe.text
    Object.set_method_enabled(recipe, 'update', Expression.is_getter(text))
end

local function update_text(self, text)
    local drawable = self.drawable
    drawable:setf(text or self.text, self.width, self.align)

    local drawable_height = drawable:getHeight()
    local vspace, valign, y = self.height - drawable_height, self.valign
    if valign == 'center' then
        self.text_offset_y = vspace * 0.5
    elseif valign == 'bottom' then
        self.text_offset_y = vspace
    else
        self.text_offset_y = 0
    end
end

function Text:create_wrapped()
    self.__initialising = true
    return love.graphics.newText(self.font or fallback_font, self.text)
end

function Text:init()
    self.__initialising = nil
    update_text(self)
end

function Text:update(dt)
    update_text(self, self.text)
end

Text.draw_push = 'all'
function Text:draw()
    Text:invoke_super('draw', self)

    local color = self.color
    if color then
        love.graphics.setColor(color)
    end

    love.graphics.draw(self.drawable, 0, self.text_offset_y)
end

Text:add_setter('text', function(self, text)
    if not self.__initialising then
        update_text(self, text)
    end
end)
Text:add_getter('textWidth', function(self)
    return self.drawable:getWidth()
end)
Text:add_getter('textHeight', function(self)
    return self.drawable:getHeight()
end)

Text.ondirty = update_text

return Text
