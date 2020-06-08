local entity = {}

function entity.loadall()
    local result = {}
    local folder = 'entities'
    for i, filename in ipairs(love.filesystem.getDirectoryItems(folder)) do
        local basename = filename:match('(.+).lua$')
        if basename then
            local system = assert(loadfile(folder .. '/' .. filename))
            entity[basename] = system
            result[#result + 1] = system
        end
    end
    return result
end

function entity.new(name)
    return assert(entity[name], "Unknown entity name: " .. name)()
end

return entity