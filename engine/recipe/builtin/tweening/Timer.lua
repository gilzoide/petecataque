local Timer = Recipe.new('Timer')

Timer.speed = 1
Timer.time = 0
Timer.running = true

function Timer:update(dt)
    if self.running then
        self.time = self.time + dt * self.speed
    end
end

return Timer
