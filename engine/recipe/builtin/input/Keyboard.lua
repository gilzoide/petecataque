local Keyboard = Recipe.new('Keyboard', 'Controller')

function Keyboard:preinit()
    self.device = 0
    self:disable_method(Recipe.setter_method_name('device'))
end

return Keyboard
