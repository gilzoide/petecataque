local function load_nested_data(filename)
    local contents, msg = love.filesystem.read(filename)
    if contents then
        return nested.decode(contents, nested.bool_number_filter)
    else
        return nil, msg
    end
end

return load_nested_data
