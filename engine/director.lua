local Director = {}

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

function Director.update(dt)
    for kp, obj in nested.iterate(Scene) do
        if obj.update then obj:update(dt) end
        process_events(obj, 'when')
        process_events(obj, 'also_when')
    end
end

function Director.draw()
    for kp, obj in nested.iterate(Scene) do
        if obj.draw and not obj.hidden then obj:draw() end
    end
end

return Director