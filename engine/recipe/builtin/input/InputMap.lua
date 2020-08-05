local InputMap = Recipe.new('InputMap')

local aggregate_keys_mt = {
    __index = function(t, index)
        if index == 'down' then
            local down, pressed, released = Input.aggregate_keys(t)
            return down or pressed
        elseif index == 'pressed' then
            local down, pressed, released = Input.aggregate_keys(t)
            return not down and pressed
        elseif index == 'released' then
            local down, pressed, released = Input.aggregate_keys(t)
            return not down and released
        end
    end,
}

function InputMap:init()
    if self.key then
        for action, keys in pairs(self.key) do
            if type(keys) ~= 'table' then keys = { keys } end
            self[action] = setmetatable(keys, aggregate_keys_mt)
        end
    end
end

Object.add_getter(InputMap, 'keyboard', function(self)
    return _ENV.keyboard
end)

return InputMap
