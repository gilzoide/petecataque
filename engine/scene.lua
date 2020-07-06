local Scene = {}
Scene.__index = Scene

function Scene.new()
    return setmetatable({}, Scene)
end

function Scene:add(obj)
    self[#self + 1] = obj
    self:track(obj)
end

function Scene:byId(id)
    return self[id]
end

function Scene:byType(typename)
    return self[typename]
end

function Scene:firstByType(typename)
    return (get(self, typename, 1))
end

function Scene:track(obj)
    local type = assert(obj[1], "Objects in scene must have a type")
    set_or_create(self, type, obj, true)

    if obj.id then
        self[obj.id] = obj
    end
end

function Scene:untrack(obj)
    local type = assert(obj[1], "Objects in scene must have a type")
    set(self, type, obj, nil)
    
    if obj.id then
        self[obj.id] = nil
    end
end

return Scene