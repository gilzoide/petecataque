return {
    'FPS',
    draw = function(self)
        if DEBUG then
            love.graphics.printf(string.format("FPS: %d", love.timer.getFPS()), 0, 0, WINDOW_WIDTH, 'right')
        end
    end
}