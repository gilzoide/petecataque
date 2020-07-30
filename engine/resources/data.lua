local function load_nested_data(filename)
    local contents = love.filesystem.read(filename)
    return nested.decode(contents, nested.bool_number_filter)
end

return load_nested_data