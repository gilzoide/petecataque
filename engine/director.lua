local Director = {}

function Director.update(dt, scene)
    scene = scene or Scene
    if scene.paused then return end
    for update, obj in scene:iterate_update() do
        DEBUG.PUSH_CALL(obj, 'update')
        update(obj, dt)
        DEBUG.POP_CALL(obj, 'update')
    end
end

function Director.draw(scene)
    scene = scene or Scene
    for draw, obj in scene:iterate_draw() do
        DEBUG.PUSH_CALL(obj, 'draw')
        draw(obj)
        DEBUG.POP_CALL(obj, 'draw')
    end
    DEBUG.ONLY(function()
        local stackDepth = love.graphics.getStackDepth()
        if stackDepth ~= 0 then
            DEBUG.WARN("MISSING POP, stackDepth = %d", stackDepth)
            for i = 1, stackDepth do love.graphics.pop() end
        end
    end)
end

return Director
