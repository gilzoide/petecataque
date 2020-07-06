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

-- Set this in a recipe to skip iterating it's children
Director.SKIP_CHILDREN = 'SKIP_CHILDREN'

function Director.update(dt)
    local iterator, skip = nested.iterate(Scene), false
    while true do
        local kp, obj = iterator(skip)
        if not kp then break end
        if obj.update then obj:update(dt) end
        process_events(obj, 'when')
        process_events(obj, 'also_when')
        skip = obj.SKIP_CHILDREN
    end
end

function Director.draw()
    local iterator, skip = nested.iterate(Scene), false
    while true do
        local kp, obj = iterator(skip)
        if not kp then break end
        if obj.draw and not obj.hidden then obj:draw() end
        skip = obj.SKIP_CHILDREN
    end
end

return Director