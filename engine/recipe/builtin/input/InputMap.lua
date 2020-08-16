local InputMap = Recipe.new('InputMap')

local aggregate_from_mt = {
    __index = function(t, index)
        if index == 'down' then
            return t.__from:is_down(unpack(t))
        elseif index == 'pressed' then
            return t.__from:is_pressed(unpack(t))
        elseif index == 'released' then
            return t.__from:is_released(unpack(t))
        end
    end,
    __from = nil,
    __pairs = default_object_pairs,
}

Object.add_setter(InputMap, 'key', function(self, value)
    if value then
        for action, keys in pairs(value) do
            if type(keys) ~= 'table' then keys = { keys } end
            keys.__from = Input.key
            self[action] = setmetatable(keys, aggregate_from_mt)
        end
    end
end)

Object.add_getter(InputMap, 'keyboard', function(self)
    return _ENV.keyboard
end)

return InputMap
