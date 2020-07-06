local Resources = {}
Resources.__index = Resources

function Resources.new()
    local resources = setmetatable({}, Resources)

    resources:register_loader('recipe', require 'recipe'.load)
    resources:register_loader('image', love.graphics.newImage)

    return resources
end

function Resources:register_loader(kind, loader)
    assertf(not self[kind], 'Resource loader %q is already registered', kind)
    self[kind] = setmetatable({}, {
        __index = function(t, index)
            local value = log.warnassert(loader(index))
            rawset(t, index, value)
            return value
        end,
        __mode = "v",
    })
end

return Resources