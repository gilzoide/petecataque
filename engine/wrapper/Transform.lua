local wrapper = require 'wrapper'

local Transform = wrapper.new('Transform', {
    'getMatrix',
}, {
    'setMatrix', 'setTransformation',
}, {
    'apply', 'clone', 'inverse', 'inverseTransformPoint', 'isAffine2DTransform',
    'reset', 'rotate', 'scale', 'shear', 'transformPoint', 'translate',
})

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
    love.graphics.applyTransform(self.__wrapped)
end

Transform["$transform"] = wrapper.get_wrapped

return Transform
