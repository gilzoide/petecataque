local KeyDetector = Recipe.new('KeyDetector')

function KeyDetector:init()
    if not self.key then
        DEBUG.WARN("Need a key to detect")
        self.paused = true
    end
end

function KeyDetector:update(dt)
    local info = key[self.key]
    self.down = info and not info.released
    self.pressed = info and info.pressed
    self.released = info and info.released
end

return KeyDetector
