local KeyDetector = {'KeyDetector'}

function KeyDetector:init()
    if not log.warnassert(self.key, "Need a key to detect") then
        self.disabled = true
    end
end

function KeyDetector:update(dt)
    local info = key[self.key]
    self.down = info and not info.released
    self.pressed = info and info.pressed
    self.released = info and info.released
end

return KeyDetector
