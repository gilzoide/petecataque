local Resources = {}
Resources.__index = Resources

local _ENV = _ENV or getfenv()
local index_env_metatable = { __index = _ENV }
local function script_loader(name)
    local filename = 'script/' .. name:gsub('%.', '/') .. '.lua'
    local script = assert(loadfile(filename))
    local constructor = function(opt_obj)
        local obj = setmetatable(opt_obj or {}, index_env_metatable)
        setfenv(script, obj)()
        return obj
    end
    _ENV[name] = constructor
    return constructor
end

local function beginContact(a, b, coll)
    emit { 'beginContact', b, coll, target = a }
    emit { 'beginContact', a, coll, target = b }
end
local function endContact(a, b, coll)
    emit { 'endContact', b, coll, target = a }
    emit { 'endContact', a, coll, target = b }
end
local function preSolve(a, b, coll)
    emit { 'preSolve', b, coll, target = a }
    emit { 'preSolve', a, coll, target = b }
end
local function postSolve(a, b, coll, normalimpulse, tangentimpulse)
    emit { 'postSolve', b, coll, normalimpulse, tangentimpulse, target = a }
    emit { 'postSolve', a, coll, normalimpulse, tangentimpulse, target = b }
end
local function world_loader(name, ...)
    local world = love.physics.newWorld(...)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    return world
end

function Resources.new()
    local resources = setmetatable({
        loader = {},
    }, Resources)

    resources:register_loader('script', script_loader)
    resources:register_loader('image', love.graphics.newImage)
    resources:register_loader('world', world_loader)

    return resources
end

function Resources:register_loader(kind, loader)
    assertf(not self.loader[kind], 'Resource loader %q is already registered', kind)
    self:set('loader', kind, loader)
    self[kind] = {}
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

function Resources:update(dt)
    for name, world in pairs(self.world) do
        world:update(dt)
    end
end

return Resources