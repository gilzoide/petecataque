local button_table = require 'input.button_table'

local position = {}
function position.new()
    return setmetatable({ 0, 0, x = 0, y = 0, changed = false }, position)
end

function position:update(x, y, dx, dy)
    self[1], self[2] = x, y
    self.x, self.y = x, y
    self.dx, self.dy = dx, dy
    self.changed = true
    InvokeQueue:queue(position.reset_moved, self)
end

function position:reset_moved()
    self.dx, self.dy, self.changed = 0, 0, false
end

position.__index = {
    update = position.update,
    reset_moved = position.reset_moved,
}

local mouse = {}

function mouse.new()
    return setmetatable({
        button_table.EMPTY, button_table.EMPTY, button_table.EMPTY,
        position = position.new(),
        wheel = position.new(),
    }, mouse)
end

function mouse:moved(x, y, dx, dy, istouch)
    self.position:update(x, y, dx, dy)
end

function mouse:pressed(x, y, button, istouch, presses)
    button_table.pressed(self, button)
end

function mouse:released(x, y, button, istouch, presses)
    button_table.released(self, button)
end

function mouse:wheelmoved(x, y)
    self.wheel:update(self.wheel.x + x, self.wheel.y + y, x, y)
end

mouse.__index = {
    moved = mouse.moved,
    pressed = mouse.pressed,
    released = mouse.released,
    wheelmoved = mouse.wheelmoved,
}

return mouse
