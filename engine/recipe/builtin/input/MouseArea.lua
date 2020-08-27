local button_table = require 'input.button_table'

local MouseArea = Recipe.new('MouseArea')

function MouseArea:init()
    self.target = self:first_parent_with('hitTestFromOrigin')
    if not self.target then
        DEBUG.WARN("Couldn't find hitTestFromOrigin in MouseArea parent")
        self:disable_method('update')
        self:disable_method('draw')
    end
    self.button = button_table.new()
end

function MouseArea:mousepressed(x, y, button, istouch, presses)
    if self.__inside then
        self.button:pressed(button)
    end
end

function MouseArea:mousereleased(x, y, button, istouch, presses)
    local mouse_buttons = self.button
    if mouse_buttons[button].down then
        local f = (self.__inside and button_table.released_inside or button_table.released_outside)
        f(mouse_buttons, button)
    end
end

function MouseArea:draw()
    if Input.mouse.position.changed then
        local x, y = love.graphics.inverseTransformPoint(unpack(Input.mouse.position))
        self.__inside = self.target:hitTestFromOrigin(x, y)
    end
end

MouseArea:add_getter('hover', function(self)
    return self.__inside
end)
MouseArea:add_getter('mouse', function(self)
    return Input.mouse
end)

return MouseArea
