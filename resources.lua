local Resources = {}
Resources.__index = Resources

local _ENV = _ENV or getfenv()
local index_env_metatable = { __index = _ENV }
local function script_loader(name)
    local filename = 'script/' .. name:gsub('%.', '/') .. '.lua'
    local script = assert(loadfile(filename))
    local constructor = function(opt_obj)
        local obj = setmetatable(opt_obj or {}, index_env_metatable)
        obj.self = obj
        setfenv(script, obj)()
        return obj
    end
    _ENV[name] = constructor
    return constructor
end

function Resources.new()
    local resources = setmetatable({
        loader = {},
    }, Resources)

    resources:register_loader('script', script_loader)
    resources:register_loader('image', love.graphics.newImage)

    return resources
end

function Resources:register_loader(kind, loader)
    assertf(not self.loader[kind], 'Resource loader %q is already registered', kind)
    self:set('loader', kind, loader)
end

function Resources:get(kind, name)
    local ofkind = self[kind]
    if ofkind == nil then
        ofkind = {}
        self[kind] = ofkind
    end
    local resource = ofkind[name]
    if resource == nil then
        local loader = assertf(self.loader[kind], "Couldn't find loader for resource of kind %q", kind)
        return loader(name)
    end
    return resource
end

function Resources:set(kind, name, value)
    local ofkind = self[kind]
    if ofkind == nil then
        ofkind = {}
        self[kind] = ofkind
    end
    ofkind[name] = value
    return value
end

function Resources:loadall(kind, ...)
    local args = {...}
    for i = 1, #args do
        self:get(kind, args[i])
    end
end

return Resources