local Director = {}

local function iterate_scene(skip_if_field)
    local iterator = Scene:iterate()
    return function()
        local kp, obj, parent, skip
        repeat
            kp, obj, parent = iterator(skip)
            skip = obj and (obj.disabled or obj[skip_if_field])
        until not skip
        return kp, obj, parent
    end
end

function Director.update(dt)
    for kp, obj in iterate_scene() do
        if obj.update then
            DEBUG.PUSH_CALL(obj, 'update')
            obj:update(dt)
            DEBUG.POP_CALL(obj, 'update')
        end
    end
end

function Director.draw()
    local pop_list = { {-1} }
    for kp, obj in iterate_scene('hidden') do
        while #kp <= pop_list[#pop_list][1] do
            local t = table.remove(pop_list)
            love.graphics.pop()
        end
        if obj.draw then
            if obj.draw_push then
                love.graphics.push(obj.draw_push)
                pop_list[#pop_list + 1] = { #kp, obj }
            end
            DEBUG.PUSH_CALL(obj, 'draw')
            obj:draw()
            DEBUG.POP_CALL(obj, 'draw')
        end
    end
    for i = #pop_list, 2, -1 do
        love.graphics.pop()
    end
    local stackDepth = love.graphics.getStackDepth()
    if not log.warnassert(stackDepth == 0, "MISSING POP, stackDepth = %d", stackDepth) then
        for i = 1, stackDepth do love.graphics.pop() end
    end
end

return Director