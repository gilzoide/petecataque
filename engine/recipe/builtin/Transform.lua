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
    local transform = love.math.newTransform(self.x, self.y, self.angle, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    self.x, self.y, self.angle, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky = nil, nil, nil, nil, nil, nil, nil, nil, nil
    return transform
end

function Transform:init()
    self:enable_method('draw', self:child_count() > 0)
end

Transform.draw_push = 'transform'

function Transform:draw()
    love.graphics.applyTransform(self.transform)
end

return Transform
