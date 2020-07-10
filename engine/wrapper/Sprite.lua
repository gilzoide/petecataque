local drawable_common = require 'wrapper.common.drawable'

local Sprite = {'Sprite'}

Sprite.anchorPoint = {0.5, 0.5}

function Sprite:init()
    drawable_common.disable_draw_if_nil(self, self.texture)
    drawable_common.disable_pop_if_no_children(self)
end

Sprite.draw = drawable_common.draw
Sprite.draw_pop = drawable_common.draw_pop
Sprite.hitTestFromOrigin = drawable_common.hitTestFromOrigin
Sprite["$set anchorPoint"] = drawable_common.setAnchorPoint

Sprite["$drawable"] = function(self)
    return self.texture
end

Sprite["$set texture"] = function(self, texture)
    if type(texture) == 'string' then
        texture = R.image[texture]
    end
    return drawable_common.setDrawable(self, texture)
end

return Sprite