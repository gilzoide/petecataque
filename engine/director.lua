local Director = {}

local function iterate_scene(scene, skip_if_field)
    local iterator = scene:iterate()
    return function()
        local kp, obj, parent, skip
        repeat
            kp, obj, parent = iterator(skip)
            skip = obj and obj[skip_if_field]
        until not skip
        return kp, obj, parent
    end
end

function Director.update(dt, scene)
    scene = scene or Scene
    if scene.paused then return end
    for kp, obj in iterate_scene(scene, 'paused') do
        obj:invoke('update', dt)
    end
end

function Director.draw(scene)
    scene = scene or Scene
    local pop_list = { {-1} }
    for kp, obj in iterate_scene(scene, 'hidden') do
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
    if stackDepth ~= 0 then
        DEBUG.WARN("MISSING POP, stackDepth = %d", stackDepth)
        for i = 1, stackDepth do love.graphics.pop() end
    end
end

return Director
