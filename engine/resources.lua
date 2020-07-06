local Resources = {}
Resources.__index = Resources

function Resources.new()
    local resources = setmetatable({
        loader = {},
    }, Resources)

    resources:register_loader('script', require 'script_loader')
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

-- function Resources:reload(kind, name, ...)
--     local loader = assertf(self.loader[kind], "Couldn't find loader for resource of kind %q", kind)
--     local resource, err = loader(name, ...)
--     if not resource then return nil, err end
--     self[kind][name] = resource
-- end

function Resources:loadall(kind, ...)
    local args = {...}
    for i = 1, #args do
        self:get(kind, args[i])
    end
end

function Resources:unload(kind, name)
    local ofkind = assertf(self[kind], "Unknown resource kind %q", kind)
    local resource = ofkind[name]
    if resource then
        if resource.destroy then resource:destroy() end
        if resource.release then resource:release() end
        ofkind[name] = nil
    end
end

return Resources