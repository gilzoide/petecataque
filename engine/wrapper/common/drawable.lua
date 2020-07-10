local drawable_common = {}

function drawable_common.disable_draw_if_nil(self, drawable)
    if not log.warnassert(drawable, "Missing drawable on %s, disabling draw", self:type()) then
        self:enable_method('draw', false)
    end
end

function drawable_common.disable_pop_if_no_children(self)
    self:enable_method('draw_pop', self:child_count() > 0)
end

function drawable_common.draw(self)
    local transform = love.math.newTransform(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
    if self.quad then
        love.graphics.draw(self.drawable, self.quad, transform)
    else
        love.graphics.draw(self.drawable, transform)
    end
    if self.draw_pop then
        love.graphics.push('transform')
        love.graphics.applyTransform(transform)
    end
end

function drawable_common.draw_pop(self)
    love.graphics.pop()
end

function drawable_common.hitTestFromOrigin(self, x, y)
    local width, height = self.drawable:getDimensions()
    return x >= 0 and x <= width
        and y >= 0 and y <= height
end

function drawable_common.refresh_anchor(self, drawable, anchorPoint)
    local width, height = drawable:getDimensions()
    self.ox = width * anchorPoint[1]
    self.oy = height * anchorPoint[2]
end

function drawable_common.setAnchorPoint(self, anchorPoint)
    anchorPoint[1] = clamp(anchorPoint[1], 0, 1)
    anchorPoint[2] = clamp(anchorPoint[2], 0, 1)
    if self.drawable then
        drawable_common.refresh_anchor(self, self.drawable, anchorPoint)
    end
end

function drawable_common.setDrawable(self, drawable)
    if drawable then
        drawable_common.refresh_anchor(self, drawable, self.anchorPoint)
    end
    drawable_common.disable_draw_if_nil(self, drawable)
    return drawable
end

return drawable_common