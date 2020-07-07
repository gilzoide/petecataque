local Graphics = {
    'Graphics',
    SKIP_CHILDREN = true,
}

function Graphics:init()
    local index_self_root_graphics = { __index = create_index_first_of{ self, self.root, love.graphics } }
    for i = 2, #self do
        setmetatable(self[i], index_self_root_graphics)
    end
end

function Graphics:draw()
    for i = 2, #self do
        local t = self[i]
        nested_function.evaluate(t, t)
    end
end

return Graphics