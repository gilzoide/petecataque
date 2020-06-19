local Director = {}
Director.__index = Director

function Director.new()
    return setmetatable({}, Director)
end

local function process_events(obj, index)
    if obj[index] then
        for i = 1, #obj[index] do
            local check = obj[index][i]
            if nested_match(obj, check[1]) then
                local handler = check[2]
                setfenv(handler, obj)()
            end
        end
    end
end

function Director:update(dt)
    for kp, obj in nested.iterate(Scene) do
        local update = obj.update
        if update then update(dt) end
        process_events(obj, 'when')
        process_events(obj, 'also_when')
    end
end

function Director:draw()
    for kp, obj in nested.iterate(Scene) do
        local draw = obj.draw
        if draw then draw() end
    end
end

return Director