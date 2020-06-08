local entity = require 'entity'

local scene = {
    loaded = {}
}

function scene.load(name)
    if not scene.loaded[name] then
        scene[name] = assert(loadfile('scenes/' .. name .. '.lua'))()
    end
    return scene[name]
end

function scene.instantiate(name)
    local formula = scene.load(name)
    local new_objects = {}
    for i, obj in ipairs(formula) do
        local ty = type(obj)
        if ty == 'table' then
            local e = entity.new(obj[1])
            for k, v in kpairs(obj) do e[k] = v end
            new_objects[#new_objects + 1] = e
        end
    end
    return new_objects
end

return scene