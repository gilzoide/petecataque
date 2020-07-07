local Director = {}

local function process_events(obj, index)
    if obj[index] then
        for i = 1, #obj[index] do
            local check = obj[index][i]
            if nested_match(obj, check[1]) then
                check[2](obj)
            end
        end
    end
end

-- Set this in a recipe to skip iterating it's children
Director.SKIP_CHILDREN = 'SKIP_CHILDREN'

local function iterate_scene()
    local iterator, skip = nested.iterate(Scene), false
    return function()
        local kp, obj, parent = iterator(skip)
        if kp then
            skip = obj.SKIP_CHILDREN
            return kp, obj, parent
        end
    end
end

function Director.update(dt)
    for kp, obj in iterate_scene() do
        if obj.update then obj:update(dt) end
        process_events(obj, 'when')
        process_events(obj, 'also_when')
    end
end

function Director.draw()
    local pop_list = { {-1} }
    for kp, obj in iterate_scene() do
        while #kp <= pop_list[#pop_list][1] do
            local t = table.remove(pop_list)
            t[2]:draw_pop()
        end
        if not obj.hidden then
            if obj.draw then obj:draw() end
            if obj.draw_pop then pop_list[#pop_list + 1] = { #kp, obj } end
        end
    end
    for i = #pop_list, 2, -1 do
        pop_list[i][2]:draw_pop()
    end
    local stackDepth = love.graphics.getStackDepth()
    if not log.warnassert(stackDepth == 0, "MISSING POP, stackDepth = %d", stackDepth) then
        for i = 1, stackDepth do love.graphics.pop() end
    end
end

return Director