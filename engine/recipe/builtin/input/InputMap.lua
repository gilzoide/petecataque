local button_table = require 'input.button_table'

local InputMap = Recipe.new('InputMap')

local function update_actions_from(self, action_map, input, clear)
    clear = not clear
    for action_name, key in pairs(action_map) do
        local action = clear and self[action_name] or button_table.EMPTY
        if type(key) == 'table' then
            for i = 1, #key do
                action = button_table.merge_state(action, input[key[i]])
            end
        else
            action = button_table.merge_state(action, input[key])
        end
        self[action_name] = action
    end
end

function InputMap:init()
    self:update()
end

function InputMap:update(dt)
    local action_map = self.keycode
    if action_map then update_actions_from(self, action_map, Input.keycode, true) end
    action_map = self.scancode
    if action_map then update_actions_from(self, action_map, Input.scancode, false) end
    action_map = self.gamepad
    if action_map then
        for i, gamepad in ipairs(action_map) do
            local input = Input.joystick[i]
            if input and input.connected then
                update_actions_from(self, gamepad, input.button, false)
            end
        end
    end
end

return InputMap
