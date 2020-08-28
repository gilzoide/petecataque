local table_stack = require 'table_stack'

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


local pop_list = table_stack.new()
pop_list:push(-1)
function pop_list:pop_until(depth)
    while depth <= self:peek()[1] do
        local method, obj = unpack(self:pop(), 2)
        method(obj)
    end
end

function Director.draw(scene)
    scene = scene or Scene
    pop_list:clear(1)
    for kp, obj in iterate_scene(scene, 'hidden') do
        local depth = #kp
        pop_list:pop_until(depth)
        
        obj:invoke('draw')

        local late_draw = obj.late_draw
        if late_draw then
            pop_list:push(depth, late_draw, obj)
        end
    end
    pop_list:pop_until(0)
    DEBUG.ONLY(function()
        local stackDepth = love.graphics.getStackDepth()
        if stackDepth ~= 0 then
            DEBUG.WARN("MISSING POP, stackDepth = %d", stackDepth)
            for i = 1, stackDepth do love.graphics.pop() end
        end
    end)
end

return Director
