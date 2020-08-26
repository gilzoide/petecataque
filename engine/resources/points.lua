local function must_be_numbers(s, quotes, line)
    return assertf(tonumber(s), "Points value must be numbers, found %q in line %d", s, line)
end

local function must_not_nest(opening, line)
    assertf(opening == '', "Cannot have nested points, found opening %s in line %d", opening, line)
end

local function root_constructor()
    return {}
end

local decode_options = {
    text_filter = must_be_numbers,
    table_constructor = must_not_nest,
    root_constructor = root_constructor,
}

local function load_points(filename, sx, sy)
    local contents = love.filesystem.read(filename)
    local data = nested.decode(contents, decode_options)
    if sx then
        for i = 1, #data, 2 do
            data[i] = sx * data[i]
        end
    end
    if sy then
        for i = 2, #data, 2 do
            data[i] = sy * data[i]
        end
    end
    return data
end

return load_points
