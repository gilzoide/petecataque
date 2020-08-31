local Director = {}

function Director.update(dt, scene)
    scene = scene or Scene
    if scene.paused then return end
    scene:call_update(dt)
end

function Director.draw(scene)
    scene = scene or Scene
    scene:call_draw()
    DEBUG.ONLY(function()
        local stackDepth = love.graphics.getStackDepth()
        if stackDepth ~= 0 then
            DEBUG.WARN("MISSING POP, stackDepth = %d", stackDepth)
            for i = 1, stackDepth do love.graphics.pop() end
        end
    end)
end

return Director
