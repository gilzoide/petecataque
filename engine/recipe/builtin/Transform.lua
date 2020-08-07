local Transform = Recipe.wrapper.new('Transform', {
    wrapped_index = 'transform',
    getters = {
        'getMatrix',
    },
    setters = {
        'setMatrix', 'setTransformation',
    },
    methods = {
        'apply', 'clone', 'inverse', 'inverseTransformPoint', 'isAffine2DTransform',
        'reset', 'rotate', 'scale', 'shear', 'transformPoint', 'translate',
    }
})

Transform.x = 0
Transform.y = 0

function Transform:create_wrapped()
    return love.math.newTransform(0, 0)
end

function Transform:update(dt)
    self.transform:setTransformation(self.x, self.y, self.angle, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
end

Transform.draw_push = 'transform'

function Transform:draw()
    love.graphics.applyTransform(self.transform)
end

return Transform
