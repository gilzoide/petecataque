local Tween = Recipe.new('Tween', 'Timer')

local easing = require 'easing'

Tween.looping = false
Tween.yoyo = false
Tween.duration = 1
Tween.from = 0
Tween.to = 1
Tween.easing = 'linear'

Object.add_setter(Tween, 'time', function(self, time)
    if time > self.duration or time < 0 then
        if self.yoyo then
            self.speed = -self.speed
        elseif self.looping then
            time = time % self.duration
        end

        self.running = self.looping
        time = clamp(time, 0, self.duration)
    end

    return time
end)

Object.add_getter(Tween, 'value', function(self)
    local from, to, time, duration = self.from, self.to, self.time, self.duration
    local f = easing[self.easing] or easing.linear
    return f(time, from, to - from, duration)
end)

Object.add_getter(Tween, 'rewinding', function(self)
    return self.speed < 0
end)

return Tween
