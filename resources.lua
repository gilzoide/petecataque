local Resources = {}
Resources.__index = Resources

local function world_loader(name, ...)
    local world = love.physics.newWorld(...)
    world:setCallbacks(
        bind(Collisions.onBeginContact, Collisions),
        bind(Collisions.onEndContact, Collisions),
        bind(Collisions.onPreSolve, Collisions),
        bind(Collisions.onPostSolve, Collisions)
    )
    return world
end

function Resources.new()
    local resources = setmetatable({
        loader = {},
    }, Resources)

    resources:register_loader('script', require 'script_loader')
    resources:register_loader('image', love.graphics.newImage)
    resources:register_loader('world', world_loader)

    return resources
end

function Resources:register_loader(kind, loader)
    assertf(not self.loader[kind], 'Resource loader %q is already registered', kind)
    self:set('loader', kind, loader)
    self[kind] = {}
end

function Resources:reload(kind, name, ...)
    local loader = assertf(self.loader[kind], "Couldn't find loader for resource of kind %q", kind)
    local resource, err = loader(name, ...)
    if not resource then return nil, err end
    self[kind][name] = resource
end

function Resources:get(kind, name, ...)
    local ofkind = assertf(self[kind], "Unknown resource kind %q", kind)
    local resource, err = ofkind[name]
    if resource == nil then
        local loader = assertf(self.loader[kind], "Couldn't find loader for resource of kind %q", kind)
        resource, err = loader(name, ...)
        if not resource then return nil, err end
        ofkind[name] = resource
    end
    return resource
end

function Resources:set(kind, name, value)
    local ofkind = assertf(self[kind], "Unknown resource kind %q", kind)
    ofkind[name] = value
    return value
end

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