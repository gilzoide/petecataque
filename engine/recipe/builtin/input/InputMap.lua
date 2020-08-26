local button_table = require 'input.button_table'

local InputMap = Recipe.new('InputMap')

function InputMap:init()
    local target = self.target
    if not target then
        target = self:first_parent_of('Controller')
        self.target = target
        DEBUG.WARNIF(not target, "Unable to create InputMap without Controller target")
    end

    self.paused = target == nil
    self:set_method_enabled('update', self.map)
end

function InputMap:update(dt)
    local target = self.target
    for k, v in pairs(self.map) do
        local merged = button_table.EMPTY
        for i, name in ipairs(v) do
            local in_target = target[name]
            if in_target then
                merged = button_table.merge(merged, in_target)
            end
        end
        self[k] = merged
    end
end

InputMap:add_setter('map', function(self, value)
    self:set_method_enabled('update', value)
end)

return InputMap
