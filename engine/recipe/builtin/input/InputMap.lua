local button_table = require 'input.button_table'

local InputMap = Recipe.new('InputMap')

function InputMap:init()
    local source = self.source
    if not source then
        source = self:first_parent_of('Controller')
        self.source = source
        DEBUG.WARNIF(not source, "Unable to create InputMap without Controller source")
    end

    self.paused = source == nil
    self:set_method_enabled('update', self.map)
end

function InputMap:update(dt)
    local source = self.source
    for k, v in pairs(self.map) do
        local merged = button_table.EMPTY
        for i, name in ipairs(v) do
            local in_target = source[name]
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
