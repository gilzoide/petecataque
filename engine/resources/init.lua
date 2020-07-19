local AssetMap = require 'resources.asset_map'

local Resources = {}
Resources.__index = Resources

Resources.path = { 'engine/recipe/builtin', 'assets' }

function Resources:index_for_parameters(name, ...)
    name = self.asset_map:full_path(name)
    return name, (select('#', ...) == 0 and name or nested.encode({ name, ... }))
end

function Resources:get(...)
    local name, index = self:index_for_parameters(...)
    return self.loaded[index]
end

function Resources:set(index, loaded_resource)
    self.loaded[index] = loaded_resource
end

function Resources:get_or_load(...)
    local name, index = self:index_for_parameters(...)
    local loaded_resource = self.loaded[index]
    if loaded_resource then
        return loaded_resource
    else
        local basename, ext = AssetMap.split_extension(name)
        local loader = assertf(self.loader_by_ext[ext], "Couldn't find loader for file %q", name)
        return loader(name, select(2, ...))
    end
end

function Resources.new()
    local resources = setmetatable({
        asset_map = AssetMap.new(Resources.path),
        loader_by_ext = {},
        loaded = setmetatable({}, { __mode = 'v' }),
    }, Resources)

    resources:register_loader('lua_recipe', require 'recipe'.tryloadlua, { '.lua' })
    resources:register_loader('recipe', require 'recipe'.tryloadnested, { '.nested' })
    resources:register_loader('image', love.graphics.newImage, { '.png', '.jpg', '.jpeg', '.bmp', '.tga', '.hdr', '.pic', '.exr' })
    resources:register_loader('font', love.graphics.newFont, { '.ttf' })

    return resources
end

local function wrap_loader(self, loader)
    return function(...)
        local name, index = self:index_for_parameters(...)
        local loaded_resource = self.loaded[index]
        if loaded_resource then
            return loaded_resource
        else
            loaded_resource = log.warnassert(loader(name, select(2, ...)))
            self:set(index, loaded_resource)
            return loaded_resource
        end
    end
end

function Resources:register_loader(kind, loader, extension_associations)
    assertf(not self[kind], 'Resource loader %q is already registered', kind)
    loader = wrap_loader(self, loader)
    self[kind] = loader
    for i, ext in ipairs(extension_associations) do
        log.warnassert(self.loader_by_ext[ext] == nil, "Overriding loader for file extension %q: %q", ext, kind)
        self.loader_by_ext[ext] = loader
    end
end

Resources.__call = Resources.get_or_load

return Resources