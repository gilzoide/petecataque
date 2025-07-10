local decode_options = {
    text_filter = nested.bool_number_filter,
}

local function load_nested_data(filename)
    if not love.filesystem.getInfo(filename) then
        return nil
    end

    local contents, msg = love.filesystem.read(filename)
    if contents then
        return nested.decode(contents, decode_options)
    else
        return nil, msg
    end
end

return load_nested_data
