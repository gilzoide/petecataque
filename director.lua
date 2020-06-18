local Director = {}
Director.__index = Director

function Director.new()
    return setmetatable({}, Director)
end

function Director:update(dt)
    for kp, obj in nested.iterate(Scene) do
        local update = obj.update
        if update then update(dt) end
        if obj.when then
            for i = 1, #obj.when do
                local check = obj.when[i]
                if nested_match(obj, check[1]) then
                    local handler = check[2]
                    setfenv(handler, obj)()
                end
            end
        end
    end
end

function Director:draw()
    for kp, obj in nested.iterate(Scene) do
        local draw = obj.draw
        if draw then draw() end
    end
end

return Director