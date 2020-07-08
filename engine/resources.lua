local Resources = {}
Resources.__index = Resources

local function loader_with_nested(loader)
    return function(s)
        local t = nested.decode(s, nested.bool_number_filter)
        if t then return loader(unpack(t))
        else return loader(s) end
    end
end

function Resources.new()
    local resources = setmetatable({}, Resources)

    resources:register_loader('recipe', require 'recipe'.load)
    resources:register_loader('image', loader_with_nested(love.graphics.newImage))
    resources:register_loader('font', loader_with_nested(love.graphics.newFont))

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

function Resources:__call(kind, name)
    return get(self, kind, name)
end

return Resources